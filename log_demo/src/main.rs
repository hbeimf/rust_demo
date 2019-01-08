extern crate flexi_logger;

#[macro_use]
extern crate log;
use flexi_logger::{Logger, detailed_format};


fn main() {

	// ...
	// Logger::with_str("info")
 //            .log_to_file()
 //            .directory("logs")
 //            .format(opt_format)
 //            .start()
 //            .unwrap_or_else(|e| panic!("Logger initialization failed with {}", e));

 // warn!("This is a warning");
 //    info!("This is an info message");
 //    debug!("This is a debug message - you must not see it!");
 //    trace!("This is a trace message - you must not see it!");


    Logger::with_str("trace")
        .format(detailed_format)
        .log_to_file()
        .directory("logs")
        .rotate_over_size(200000000000)
        .o_timestamp(true)
        .start_reconfigurable()
        .unwrap_or_else(|e| panic!("Logger initialization failed with {}", e));

    

    error!("This is an error message");
    warn!("This is a warning");
    info!("This is an info message");
    debug!("This is a debug message - you must not see it!");
    trace!("This is a trace message - you must not see it!");



 // Logger::with_str("trace")
 //        .format(detailed_format)
 //        .log_to_file()
 //        .discriminant("foo")
 //        .start_reconfigurable()
 //        .unwrap_or_else(|e| panic!("Logger initialization failed with {}", e));

 //    error!("This is an error message");
 //    warn!("This is a warning");
 //    info!("This is an info message");
 //    debug!("This is a debug message - you must not see it!");
 //    trace!("This is a trace message - you must not see it!");
}