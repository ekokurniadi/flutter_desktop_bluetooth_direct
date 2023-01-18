use bluest::Adapter;

use flutter_rust_bridge::frb;
use futures_util::StreamExt;
use std::error::Error;
use std::str::FromStr;
use tracing::metadata::LevelFilter;
use tracing::{info, warn};
use tracing_subscriber::prelude::*;
use tracing_subscriber::{fmt, EnvFilter};
use uuid::Uuid;

#[frb(dart_metadata=("freezed", "immutable" import "package:meta/meta.dart" as meta))]
pub struct BluetoothDevice {
    pub name: Option<String>,
    pub address: Option<String>,
    pub status: bool,
    pub service_uuid: Vec<String>,
}

/// INIT LOGGER
#[tokio::main]
pub async fn init_() {
    let _registry = tracing_subscriber::registry()
        .with(fmt::layer())
        .with(
            EnvFilter::builder()
                .with_default_directive(LevelFilter::INFO.into())
                .from_env_lossy(),
        )
        .init();
}

/// CHECK BLUETOOTH IS EXIST OR NOT
#[tokio::main]
pub async fn get_adapter_state() -> Result<bool, Box<dyn Error>> {
    let adapter_manager = Adapter::default()
        .await
        .ok_or("Bluetooth Adapter Not Found");

    if let Ok(_adapter) = adapter_manager {
        Ok(true)
    } else {
        Ok(false)
    }
}

/// INFO : DISCOVER BLUETOOTH DEVICE
#[tokio::main]
pub async fn discover_device() -> Result<Vec<BluetoothDevice>, Box<dyn Error>> {
    let mut list_of_device: Vec<BluetoothDevice> = Vec::new();

    let adapter_manager = Adapter::default()
        .await
        .ok_or("Bluetooth Adapter Not Found");
    if let Ok(_adapter) = adapter_manager {
        let discovered_device = {
            info!("starting scan");
            let mut scan = _adapter.scan(&[]).await?;
            info!("scan started");
            scan.next().await.ok_or("scan terminated")?
        };

        let mut service_uuids: Vec<String> = Vec::new();
        for sid in discovered_device.adv_data.services.iter() {
            service_uuids.push(sid.to_string());
        }

        let blue_device = BluetoothDevice {
            name: Some(
                discovered_device
                    .device
                    .name()
                    .unwrap_or(String::from("Unknown")),
            ),
            address: Some(discovered_device.device.id().to_string()),
            service_uuid: service_uuids,
            status: discovered_device.adv_data.is_connectable,
        };

        list_of_device.push(blue_device);
    }

    Ok(list_of_device)
}

/// INFO : CONNECT TO DEVICE
#[tokio::main]
pub async fn connect_to_device(service_uuid: String) -> Result<bool, Box<dyn Error>> {
    let adapter = Adapter::default()
        .await
        .ok_or("Bluetooth adapter not found");

    if let Ok(_adapter_exist) = adapter {
        let uuid: Uuid = Uuid::from_str(&service_uuid).unwrap();

        let device = _adapter_exist
            .discover_devices(&[uuid])
            .await?
            .next()
            .await
            .ok_or("Failed to discover device")??;

        let connect = _adapter_exist.connect_device(&device).await;
        if let Ok(_connect_result) = connect {
            info!(
                "connected to {:?}",
                device.name().as_deref().unwrap_or("(unknown)")
            );
        } else {
            info!("error, skipping connection");
        }
        Ok(true)
    } else {
        Ok(false)
    }
}

#[tokio::main]
pub async fn disconnect(service_uuid: String) -> Result<bool, Box<dyn Error>> {
    let adapter = Adapter::default()
        .await
        .ok_or("Bluetooth adapter not found")?;
    adapter.wait_available().await?;

    let uuid: Uuid = Uuid::from_str(&service_uuid).unwrap();

    let device = adapter
        .discover_devices(&[uuid])
        .await?
        .next()
        .await
        .ok_or("Failed to discover device")??;

    let connect = adapter.disconnect_device(&device).await;
    if let Ok(_connect_result) = connect {
        Ok(true)
    } else {
        Ok(false)
    }
}

#[tokio::main]
pub async fn start_printer(service_uuid: String, data: Vec<u8>) -> Result<(), Box<dyn Error>> {
    let adapter = Adapter::default()
        .await
        .ok_or("Bluetooth adapter not found")?;
    adapter.wait_available().await?;

    let uuid: Uuid = Uuid::from_str(&service_uuid).unwrap();

    info!("looking for device");
    
    let device = adapter
        .discover_devices(&[uuid])
        .await?
        .next()
        .await
        .ok_or("Failed to discover device")??;

    info!(
        "found device: {} ({:?})",
        device.name().as_deref().unwrap_or("(unknown)"),
        device.id()
    );

    adapter.connect_device(&device).await?;
    info!("connected!");

    let service = match device.discover_services_with_uuid(uuid).await?.get(0) {
        Some(service) => service.clone(),
        None => return Err("service not found".into()),
    };
    info!("found printer service");

    let characteristics = service.discover_characteristics().await?;
    info!("discovered characteristics");

    info!("start print");
    for c in characteristics {
        let res = c.write(&data).await.is_ok();
        if res {
            info!("write data to {:?}", c.uuid());
        } else {
            warn!("failed to send data, skipping on {:?}", c.uuid());
        }
    }

    Ok(())
}
