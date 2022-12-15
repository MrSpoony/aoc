use std::collections::HashSet;

const SEARCH_Y: i64 = 2000000;
const MAX_SEARCH: i64 = 4000000;

fn main() {
    let mut occupied: HashSet<i64> = HashSet::new();
    let sensors = include_str!("../input.txt")
        .lines()
        .map(|line| {
            line.strip_prefix("Sensor at x=")
                .unwrap()
                .replace(": closest beacon is at x=", ", ")
                .replace(", y=", ", ")
                .split(", ")
                .map(|s| s.parse::<i64>().unwrap())
                .collect::<Vec<_>>()
        })
        .collect::<Vec<_>>();
    for sensor in sensors.iter() {
        let (sx, sy, bx, by) = (sensor[0], sensor[1], sensor[2], sensor[3]);
        let (dx, dy): (i64, i64) = (sx.abs_diff(bx) as i64, sy.abs_diff(by) as i64);
        let diff = dx + dy;
        let diff_to_search = sy.abs_diff(SEARCH_Y) as i64;
        if diff_to_search <= diff {
            for i in sx - (diff - diff_to_search)..=sx + (diff - diff_to_search) {
                occupied.insert(i);
            }
        }
    }
    for sensor in sensors.iter() {
        let (x, y) = (sensor[2], sensor[3]);
        if y == SEARCH_Y {
            occupied.remove(&x);
        }
    }
    println!("{:?}", occupied.len());
    // I know it's slow as hell but I don't have the time to optimize it
    'all: for sensor in sensors.iter() {
        let (sx, sy, bx, by) = (sensor[0], sensor[1], sensor[2], sensor[3]);
        let (dx, dy): (i64, i64) = (sx.abs_diff(bx) as i64, sy.abs_diff(by) as i64);
        let diff = dx + dy;
        for x in sx - diff - 1..=sx + diff + 1 {
            if x > MAX_SEARCH {
                break;
            } else if x < 0 {
                continue;
            }
            let dy = diff - (x - sx).abs() + 1;
            'outer: for y in vec![sy + dy, sy - dy] {
                if y > MAX_SEARCH || y < 0 {
                    continue;
                }
                for other in sensors.iter() {
                    let (osx, osy, obx, oby) = (other[0], other[1], other[2], other[3]);
                    let (odx, ody): (i64, i64) =
                        (osx.abs_diff(obx) as i64, osy.abs_diff(oby) as i64);
                    let odiff = odx + ody;
                    if (other[0] - x).abs() + (other[1] - y).abs() <= odiff {
                        break 'outer;
                    }
                }
                println!("{}", x * 4000000 + y);
                break 'all;
            }
        }
    }
}
