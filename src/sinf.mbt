// const SIN_SWITCHOVER: f32 = 201.15625;
// const COS_SWITCHOVER: f32 = 142.90625;
//
// // static unsigned two_over_pi[] = {
// //     0x00000000,
// //     0x28be60db,
// //     0x9391054a,
// //     0x7f09d5f4,
// //     0x7d4d3770,
// //     0x36d8a566,
// //     0x4f10e410,
// // };
//
// fn float(x: u32) -> f32 {
//     f32::from_bits(x)
// }
//
// fn integer(x: f32) -> u32 {
//     x.to_bits() as u32
// }
//
// fn mulh(a: u32, b: u32) -> u32 {
//     let a = a as u64;
//     let b = b as u64;
//     let res = a * b;
//     (res >> 32) as u32
// }
//
// fn mul(a: u32, b: u32) -> (u32, u32) {
//     let a = a as u64;
//     let b = b as u64;
//     let res = a * b;
//     ((res >> 32) as u32, res as u32)
// }
//
// fn trig_reduce(x: f32, switch_over: f32) -> (f32, i32) {
//     if x.abs() <= switch_over {
//         let mut j: f32;
//         let mut r: f32;
//         j = x * float(0x3f22f983) + float(0x4b40_0000);
//         j = (integer(j) - 0x4b40_0000) as f32;
//         r = x - j * float(0x3fc90f80);
//         r = r - j * float(0x37354440);
//         r = r - j * float(0x2c34611a);
//         return (r, j as i32);
//     }
//
//     let xispos = x >= 0.0;
//     let mut exp: i32 = (((x.to_bits() >> 23) & 0xff) - 126) as i32;
//     let ix = ((integer(x) & 0x007fffff) << 8) | 0x80000000;
//     let ind = (exp >> 5) as usize;
//     exp = exp & 0x1f;
//
//     let two_over_pi = [
//         0x00000000, 0x28be60db, 0x9391054a, 0x7f09d5f4, 0x7d4d3770, 0x36d8a566, 0x4f10e410,
//     ];
//
//     let mut hi = two_over_pi[ind];
//     let mut mi = two_over_pi[ind + 1];
//     let mut lo = two_over_pi[ind + 2];
//     let tp = two_over_pi[ind + 3];
//
//     if exp > 0 {
//         hi = (hi << exp) | (mi >> (32 - exp));
//         mi = (mi << exp) | (lo >> (32 - exp));
//         lo = (lo << exp) | (tp >> (32 - exp));
//     }
//
//     let mut phi: u32;
//     let mut plo: u32;
//     let mut l: u32;
//     let h: u32;
//
//     (phi, _) = mul(ix, lo);
//
//     (h, l) = mul(ix, mi);
//
//     plo = phi + l;
//     phi = h + (plo < l) as u32;
//
//     (_, l) = mul(ix, hi);
//     phi = phi + l;
//
//     let mut q: i32 = (phi >> 30) as i32;
//     phi = phi & 0x3fffffff;
//     if phi & 0x2000_0000 != 0 {
//         phi = phi.wrapping_sub(0x4000_0000);
//         q = q + 1;
//     }
//
//     let s: u32 = phi & 0x8000_0000;
//     if phi >= 0x8000_0000 {
//         phi = !phi;
//         plo = 0_u32.wrapping_sub(plo);
//         phi += (plo == 0) as u32;
//     }
//
//     exp = 0;
//     while phi < 0x8000_0000 {
//         phi = (phi << 1) | (plo >> 31);
//         plo = plo << 1;
//         exp = exp.wrapping_sub(1);
//     }
//
//     phi = mulh(phi, 0xc90f_daa2);
//     if phi < 0x8000_0000 {
//         phi = phi << 1;
//         exp = exp.wrapping_sub(1);
//     }
//
//     let mut r = s + ((exp + 128) << 23) as u32 + (phi >> 8) + ((phi & 0xff) > 0x7e) as u32;
//     if !xispos {
//         r ^= 0x8000_0000;
//         q = -q;
//     }
//
//     let r = float(r);
//
//     return (r, q);
// }
//
// fn sin_poly(x: f32) -> f32 {
//     let s = x * x;
//     let mut r = float(0x3640_5000);
//     r = r * s - float(0x3950_3486);
//     r = r * s + float(0x3c08_88c1);
//     r = r * s - float(0x3e2a_aaab);
//     let t = x * s;
//     r = r * t + x;
//     r
// }
//
// fn cos_poly(x: f32) -> f32 {
//     let s = x * x;
//     let mut r = float(0x37cd_4000);
//     r = r * s - float(0x3ab6_077d);
//     r = r * s + float(0x3d2a_aaa8);
//     r = r * s - float(0x3f00_0000);
//     r = r * s + float(0x3f80_0000);
//     r
// }
//
// fn sin_cos_core(x: f32, q: i32) -> f32 {
//     let mut r = if q & 1 != 0 { cos_poly(x) } else { sin_poly(x) };
//     if q & 2 != 0 {
//         r = -r;
//     }
//     r
// }
//
// fn sin(x: f32) -> f32 {
//     if x.is_nan() || x.is_infinite() {
//         return f32::NAN;
//     }
//     if x == 0.0 {
//         return x;
//     }
//     let (x, q) = trig_reduce(x, SIN_SWITCHOVER);
//     sin_cos_core(x, q)
// }
//
// fn cos(x: f32) -> f32 {
//     if x.is_nan() || x.is_infinite() {
//         return f32::NAN;
//     }
//     if x == 0.0 {
//         return 1.0;
//     }
//     let (x, q) = trig_reduce(x, COS_SWITCHOVER);
//     sin_cos_core(x, q + 1)
// }
