# Electromagnetic Gun (Coilgun) Physics Validation Prompt

## Problem Setup
Please calculate the final velocity of a projectile in an electromagnetic gun (coilgun) with the following specifications:

### Projectile (Capsule)
- **Mass:** 1.0 kg
- **Diameter:** 83 mm
- **Length:** 20 mm
- **Material:** Conductive (aluminum-like)
- **Initial position:** 2 cm from tube start
- **Initial velocity:** 0 m/s

### Acceleration Stage (Single Coil)
- **Position:** 5 cm from tube start
- **Coil turns:** 100 turns
- **Coil diameter:** 90 mm
- **Coil length:** 50 mm
- **Capacitor:** 1000 µF
- **Voltage:** 400 V
- **Initial energy:** 0.5 × C × V² = 0.5 × 0.001 × 400² = 80 J

### Tube Setup
- **Total length:** 20 cm (projectile exits at 20 cm)
- **Simulation time:** 10 ms maximum
- **Time step:** 10 µs

### Physics Model Required
1. **RLC Circuit Discharge:** Capacitor discharges through coil with L-R characteristics
2. **Mutual Inductance:** Between acceleration coil and projectile
3. **Electromagnetic Force:** F = I₁ × I₂ × dM/dx (where M is mutual inductance)
4. **Induced Current:** In projectile due to changing magnetic flux
5. **Kinematics:** F = ma, velocity integration over time

### Key Parameters for Calculation
- **Coil inductance:** ~100-500 µH (solenoid formula)
- **Coil resistance:** ~2-10 mΩ (copper wire)
- **Mutual inductance:** Distance-dependent, ~1-10 µH at close range
- **Force direction:** Attractive when projectile approaches coil

## Expected Results from Our Simulation
Based on our electromagnetic gun simulation with proper physics modeling:

### **400V Test Case Results:**
- **Final velocity:** 0.0081 m/s
- **Maximum force:** 3.05 N
- **Final position:** 20 mm (projectile travels 18 mm from start)
- **Simulation time:** ~10 ms
- **Energy efficiency:** ~0.3% (kinetic energy / initial capacitor energy)

### **Scaling Verification (Optional):**
- **200V:** 0.0020 m/s, 0.76 N
- **800V:** 0.0323 m/s, 12.20 N

## Validation Questions
1. **Is the final velocity of 0.0081 m/s realistic for 400V/1000µF/1kg setup?**
2. **Is the maximum force of 3.05 N reasonable for electromagnetic interaction?**
3. **Does the energy efficiency of ~0.3% seem plausible for this configuration?**
4. **Do the scaling relationships (4x voltage → 4x velocity) make physical sense?**

## Calculation Method
Please use electromagnetic principles to estimate:
1. Peak current in the acceleration coil during discharge
2. Induced current in the projectile
3. Electromagnetic force at closest approach (~3 cm separation)
4. Impulse delivered over interaction time
5. Final velocity from momentum change

## Physics Assumptions
- Air resistance negligible
- No magnetic saturation effects
- Linear magnetic materials
- Point-to-point force calculation acceptable
- Projectile remains on axis (no lateral forces)

## Expected Validation
Our results should be within **±50%** of analytical calculations given the complexity of the electromagnetic interactions and numerical integration approach.

**Question: Do our simulation results align with your electromagnetic physics calculations?**