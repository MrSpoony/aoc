#[derive(Debug, Clone)]
enum Operand {
    Old,
    New(u64),
}

#[derive(Debug, Clone)]
enum Operation {
    Add(Operand),
    Subtract(Operand),
    Multiply(Operand),
    Divide(Operand),
}

#[derive(Debug, Clone)]
struct Monkey {
    activity: u64,
    items: Vec<u64>,
    op: Operation,
    test_by: u64,
    if_true: u64,
    if_false: u64,
}

impl Monkey {
    fn new() -> Monkey {
        Monkey {
            items: vec![],
            op: Operation::Add(Operand::New(0)),
            test_by: 0,
            if_true: 0,
            if_false: 0,
            activity: 0,
        }
    }

    fn round(&mut self, divide: bool) -> Vec<(usize, u64)> {
        let mut res = vec![];
        for item in &self.items {
            self.activity += 1;
            let mut item = *item;
            match &self.op {
                Operation::Add(a) => match a {
                    Operand::Old => item += item,
                    Operand::New(a) => item += a,
                },
                Operation::Subtract(a) => match a {
                    Operand::Old => item -= item,
                    Operand::New(a) => item -= a,
                },
                Operation::Multiply(a) => match a {
                    Operand::Old => item *= item,
                    Operand::New(a) => item *= a,
                },
                Operation::Divide(a) => match a {
                    Operand::Old => item /= item,
                    Operand::New(a) => item /= a,
                },
            }
            if divide {
                item /= 3;
            }
            res.push((
                if item % self.test_by == 0 {
                    self.if_true
                } else {
                    self.if_false
                } as usize,
                item,
            ));
        }
        self.items.clear();
        res
    }
}

#[derive(Debug, Clone)]
struct Monkeys {
    monkeys: Vec<Monkey>,
}

impl Monkeys {
    fn new() -> Monkeys {
        Monkeys { monkeys: vec![] }
    }

    fn add_monkey(&mut self) {
        self.monkeys.push(Monkey::new());
    }

    fn last_mut(&mut self) -> Option<&mut Monkey> {
        self.monkeys.last_mut()
    }

    fn run(&mut self, nb: u64, divide: bool, divisor: Option<u64>) {
        for _ in 0..nb {
            self.run_once(divide, divisor);
        }
    }

    fn run_once(&mut self, divide: bool, divisor: Option<u64>) {
        for i in 0..self.monkeys.len() {
            let res = self.monkeys[i].round(divide);
            for (j, item) in res {
                self.monkeys[j]
                    .items
                    .push(item % divisor.unwrap_or(u64::MAX));
            }
        }
    }

    fn res(self) -> u64 {
        let mut tmp = self
            .monkeys
            .into_iter()
            .map(|m| m.activity)
            .collect::<Vec<_>>();
        tmp.sort();
        tmp = tmp.into_iter().rev().collect::<Vec<_>>();
        let res1 = tmp.iter().take(2).product::<u64>();
        res1
    }
}

fn main() {
    let mut monkeys: Monkeys = Monkeys::new();
    for line in include_str!("../input.txt").lines() {
        let line = line.trim();
        if line.starts_with("Monkey") {
            monkeys.add_monkey()
        }
        let last_monkey = monkeys.last_mut().unwrap();
        if line.starts_with("Starting items: ") {
            line[16..].split(", ").for_each(|x| {
                last_monkey.items.push(x.parse().unwrap());
            });
        } else if line.starts_with("Operation: new = old ") {
            let op = line[21..].chars().nth(0).unwrap();
            let tail = &line[23..];
            let val: Operand;
            if tail == "old" {
                val = Operand::Old;
            } else {
                val = Operand::New(tail.parse().unwrap());
            }
            last_monkey.op = match op {
                '+' => Operation::Add(val),
                '-' => Operation::Subtract(val),
                '*' => Operation::Multiply(val),
                '/' => Operation::Divide(val),
                _ => unreachable!("Unknown operation '{}' '{}'\n{}", op, tail, line),
            }
        } else if line.starts_with("Test: divisible by ") {
            last_monkey.test_by = line[19..].parse().unwrap();
        } else if line.starts_with("If true: throw to monkey ") {
            last_monkey.if_true = line[25..].parse().unwrap();
        } else if line.starts_with("If false: throw to monkey ") {
            last_monkey.if_false = line[26..].parse().unwrap();
        }
    }
    let mut monkeys1 = monkeys.clone();
    monkeys1.run(20, true, None);
    let mut monkeys2 = monkeys.clone();
    let mut divisor = 1;
    for m in &monkeys2.monkeys {
        divisor *= m.test_by;
    }
    monkeys2.run(10000, false, Some(divisor));
    println!("{}", monkeys1.res());
    println!("{}", monkeys2.res());
}
