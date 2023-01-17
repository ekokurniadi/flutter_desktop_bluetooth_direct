pub use bluest::{Adapter, Uuid};

use futures_util::StreamExt;
pub use std::error::Error;
pub use std::time::Duration;
pub use tokio::time;
use tracing::metadata::LevelFilter;
use tracing::info;
use tracing_subscriber::prelude::*;
use tracing_subscriber::{fmt, EnvFilter};

pub struct BluetoothDevice {
    pub name: Option<String>,
    pub address: Option<String>,
    pub status: bool,
}

const BLUETOOTH_PRINTER_SERVICE_UUID: Uuid =
    Uuid::from_u128(0x000018f0_0000_1000_8000_00805f9b34fb);
const BLUETOOTH_PRINTER_STATE_CHARACTERISTIC_PRIMARY: Uuid =
    Uuid::from_u128(0x00002AF0_0000_1000_8000_00805F9B34FB);
const BLUETOOTH_PRINTER_STATE_CHARACTERISTIC_SECOND: Uuid =
    Uuid::from_u128(0x00002AF1_0000_1000_8000_00805F9B34FB);

#[tokio::main]
pub async fn get_adapter() -> Result<Vec<BluetoothDevice>, Box<dyn Error>> {
    let mut discovered_device: Vec<BluetoothDevice> = Vec::new();

    let adapter = Adapter::default()
        .await
        .ok_or("Bluetooth adapter not found")?;
    adapter.wait_available().await?;

    info!("looking for device");


    let device = adapter
        .discover_devices(&[BLUETOOTH_PRINTER_SERVICE_UUID])
        .await?
        .next()
        .await
        .ok_or("Failed to discover device")??;
    info!(
        "found device: {} ({:?})",
        device.name().as_deref().unwrap_or("(unknown)"),
        device.id(),
    );

    

    let bluetooth_devices = BluetoothDevice {
        name: Some(device.name().unwrap()),
        address: Some(device.id().to_string()),
        status: device.is_connected().await,
    };

    discovered_device.push(bluetooth_devices);

    Ok(discovered_device)
}


#[tokio::main]
pub async fn connect(data: Vec<u8>) -> Result<(), Box<dyn Error>> {
    let adapter = Adapter::default()
        .await
        .ok_or("Bluetooth adapter not found")?;
    adapter.wait_available().await?;

    info!("looking for device");
    let device = adapter
        .discover_devices(&[BLUETOOTH_PRINTER_SERVICE_UUID])
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

    let service = match device
        .discover_services_with_uuid(BLUETOOTH_PRINTER_SERVICE_UUID)
        .await?
        .get(0)
    {
        Some(service) => service.clone(),
        None => return Err("service not found".into()),
    };
    info!("found printer service");

    let characteristics = service.discover_characteristics().await?;
    info!("discovered characteristics");

    let printer = characteristics
        .iter()
        .find(|x| x.uuid() == BLUETOOTH_PRINTER_STATE_CHARACTERISTIC_SECOND)
        .ok_or("printer characteristic not found")?;

    info!("start print");

    printer.write(&data).await?;

    Ok(())
}

#[tokio::main]
pub async fn init_() {
    tracing_subscriber::registry()
        .with(fmt::layer())
        .with(
            EnvFilter::builder()
                .with_default_directive(LevelFilter::INFO.into())
                .from_env_lossy(),
        )
        .init();
}
