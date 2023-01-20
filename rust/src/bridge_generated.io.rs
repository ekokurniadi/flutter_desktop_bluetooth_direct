use super::*;
// Section: wire functions

#[no_mangle]
pub extern "C" fn wire_init_(port_: i64) {
    wire_init__impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_get_adapter_state(port_: i64) {
    wire_get_adapter_state_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_discover_device(port_: i64) {
    wire_discover_device_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_connect_to_device(port_: i64, service_uuid: *mut wire_uint_8_list) {
    wire_connect_to_device_impl(port_, service_uuid)
}

#[no_mangle]
pub extern "C" fn wire_disconnect(port_: i64, service_uuid: *mut wire_uint_8_list) {
    wire_disconnect_impl(port_, service_uuid)
}

#[no_mangle]
pub extern "C" fn wire_start_printer(
    port_: i64,
    service_uuid: *mut wire_uint_8_list,
    data: *mut wire_uint_8_list,
) {
    wire_start_printer_impl(port_, service_uuid, data)
}

#[no_mangle]
pub extern "C" fn wire_discover_device_stream(port_: i64) {
    wire_discover_device_stream_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_stop_scan(port_: i64) {
    wire_stop_scan_impl(port_)
}

// Section: allocate functions

#[no_mangle]
pub extern "C" fn new_uint_8_list_0(len: i32) -> *mut wire_uint_8_list {
    let ans = wire_uint_8_list {
        ptr: support::new_leak_vec_ptr(Default::default(), len),
        len,
    };
    support::new_leak_box_ptr(ans)
}

// Section: related functions

// Section: impl Wire2Api

impl Wire2Api<String> for *mut wire_uint_8_list {
    fn wire2api(self) -> String {
        let vec: Vec<u8> = self.wire2api();
        String::from_utf8_lossy(&vec).into_owned()
    }
}

impl Wire2Api<Vec<u8>> for *mut wire_uint_8_list {
    fn wire2api(self) -> Vec<u8> {
        unsafe {
            let wrap = support::box_from_leak_ptr(self);
            support::vec_from_leak_ptr(wrap.ptr, wrap.len)
        }
    }
}
// Section: wire structs

#[repr(C)]
#[derive(Clone)]
pub struct wire_uint_8_list {
    ptr: *mut u8,
    len: i32,
}

// Section: impl NewWithNullPtr

pub trait NewWithNullPtr {
    fn new_with_null_ptr() -> Self;
}

impl<T> NewWithNullPtr for *mut T {
    fn new_with_null_ptr() -> Self {
        std::ptr::null_mut()
    }
}

// Section: sync execution mode utility

#[no_mangle]
pub extern "C" fn free_WireSyncReturn(ptr: support::WireSyncReturn) {
    unsafe {
        let _ = support::box_from_leak_ptr(ptr);
    };
}
