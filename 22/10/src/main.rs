#[derive(Debug)]
struct CRT {
    display: Vec<String>,
}

impl CRT {
    fn new() -> CRT {
        CRT {
            display: vec![String::new(); 6],
        }
    }

    fn render(&mut self, ops: Vec<i32>) {
        let mut cycle: i32 = 1;
        let mut val: i32 = 1;
        self.display[0].push_str("#");
        for ele in ops {
            if ele != 0 {
                cycle += 1;
                if cycle > 240 {
                    break;
                }
                self.display[((cycle - 1) / 40) as usize].push_str(
                    if (val - cycle + 1 as i32).abs() > 1 {
                        "."
                    } else {
                        "#"
                    },
                );
                if cycle % 40 == 0 && cycle != 0 {
                    val += 40;
                }
            }
            cycle += 1;
            val += ele;
            if cycle > 240 {
                break;
            }
            self.display[((cycle - 1) / 40) as usize].push_str(
                if (val - cycle + 1 as i32).abs() > 1 {
                    "."
                } else {
                    "#"
                },
            );
            if cycle % 40 == 0 && cycle != 0 {
                val += 40;
            }
        }
    }

    fn print(&self) {
        for line in &self.display {
            println!("{}", line);
        }
    }
}

fn main() {
    let x = include_str!("../input.txt")
        .lines()
        .map(|line| {
            if line == "noop" {
                0
            } else {
                line.split_whitespace()
                    .nth(1)
                    .unwrap()
                    .parse::<i32>()
                    .unwrap()
            }
        })
        .collect::<Vec<_>>();

    let mut cycle = 1;
    let mut res = vec![];
    let mut val = 1;
    for ele in x.clone() {
        if ele != 0 {
            cycle += 1;
            if (cycle + 20) % 40 == 0 {
                res.push(val * cycle);
            }
        }
        cycle += 1;
        val += ele;
        if (cycle + 20) % 40 == 0 {
            res.push(val * cycle);
        }
    }

    let mut crt = CRT::new();
    crt.render(x);

    println!("{}", res.iter().sum::<i32>());
    crt.print();
}
