/// -*- tab-width: 4; Mode: C++; c-basic-offset: 4; indent-tabs-mode: nil -*-
#if FRAME_CONFIG == HELI_FRAME
/*
 * heli_control_stabilize.pde - init and run calls for stabilize flight mode for trad heli
 */

// stabilize_init - initialise stabilize controller
static bool heli_stabilize_init(bool ignore_checks)
{
    // set target altitude to zero for reporting
    // To-Do: make pos controller aware when it's active/inactive so it can always report the altitude error?
    pos_control.set_alt_target(0);
    return true;
}

// stabilize_run - runs the main stabilize controller
// should be called at 100hz or more
static void heli_stabilize_run()
{
    int16_t target_roll, target_pitch;
    float target_yaw_rate;
    int16_t pilot_throttle_scaled;

    // To-Do: should tradheli reset roll, pitch, yaw targets when motors are not runup?

    // apply SIMPLE mode transform to pilot inputs
    update_simple_mode();

    // convert pilot input to lean angles
    // To-Do: convert get_pilot_desired_lean_angles to return angles as floats
    get_pilot_desired_lean_angles(g.rc_1.control_in, g.rc_2.control_in, target_roll, target_pitch);

    // get pilot's desired yaw rate
    target_yaw_rate = get_pilot_desired_yaw_rate(g.rc_4.control_in);

    // get pilot's desired throttle
    pilot_throttle_scaled = get_pilot_desired_throttle(g.rc_3.control_in);

    // call attitude controller
    attitude_control.angleef_rp_rateef_y(target_roll, target_pitch, target_yaw_rate);

    // output pilot's throttle - note that TradHeli does not used angle-boost
    attitude_control.set_throttle_out(pilot_throttle_scaled, false);

    // re-fetch angle targets for reporting
    const Vector3f angle_target = attitude_control.angle_ef_targets();
    control_roll = angle_target.x;
    control_pitch = angle_target.y;
    control_yaw = angle_target.z;

    // update estimate of throttle cruise
    update_throttle_cruise(motors.get_collective_out());
}

#endif  //HELI_FRAME