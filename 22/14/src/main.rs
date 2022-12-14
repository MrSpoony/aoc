use std::{collections::HashSet, str::FromStr};

#[derive(Debug, Clone)]
struct Cave {
    map: HashSet<(i32, i32)>,
    floor: i32,
}

impl FromStr for Cave {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let mut cave = Cave {
            map: HashSet::new(),
            floor: 0,
        };
        s.lines()
            .map(|line| {
                line.split(" -> ")
                    .map(|pair| {
                        let (a, b) = pair.split_once(",").unwrap();
                        (a.parse::<i32>().unwrap(), b.parse::<i32>().unwrap())
                    })
                    .collect::<Vec<_>>()
            })
            .for_each(|line| {
                for i in 1..line.len() {
                    for j in line[i].min(line[i - 1]).0..=line[i].0.max(line[i - 1].0) {
                        for k in line[i].1.min(line[i - 1].1)..=line[i].1.max(line[i - 1].1) {
                            cave.map.insert((j, k));
                        }
                    }
                }
            });
        cave.floor = cave.map.iter().map(|(_, y)| y).max().unwrap() + 2;
        return Ok(cave);
    }
}

impl Cave {
    fn simulate_infinite(&mut self, start: (i32, i32)) -> usize {
        let mut res = 0;
        while self.drop_one_inf(start) {
            res += 1;
        }
        res
    }

    fn simulate_floor(&mut self, start: (i32, i32)) -> usize {
        let mut res = 0;
        while self.get(&start).is_none() {
            self.drop_one_floor(start);
            res += 1;
        }
        res
    }

    fn drop_one_floor(&mut self, start: (i32, i32)) {
        let mut curr = (start.0, start.1 - 1);
        'outer: loop {
            if curr.1 + 1 >= self.floor {
                break;
            }
            for i in vec![0, -1, 1].iter() {
                if self.get(&(curr.0 + i, curr.1 + 1)).is_none() {
                    curr = (curr.0 + i, curr.1 + 1);
                    continue 'outer;
                }
            }
            break;
        }
        self.map.insert(curr);
    }

    fn get(&self, pos: &(i32, i32)) -> Option<(i32, i32)> {
        if pos.1 >= self.floor {
            return Some(*pos);
        }
        return self.map.get(&pos).copied();
    }

    fn drop_one_inf(&mut self, start: (i32, i32)) -> bool {
        let mut curr = start;
        'outer: loop {
            if curr.1 >= self.floor {
                return false;
            }
            for i in vec![0, -1, 1].iter() {
                if self.map.get(&(curr.0 + i, curr.1 + 1)).is_none() {
                    curr = (curr.0 + i, curr.1 + 1);
                    continue 'outer;
                }
            }
            self.map.insert(curr);
            break;
        }
        true
    }

    fn _print(self) {
        for i in 480..=520 {
            for j in 0..=25 {
                match self.map.get(&(i, j)) {
                    Some(_) => print!("#"),
                    None => print!("."),
                }
            }
            println!();
        }
    }
}

fn main() {
    let mut cave = Cave::from_str(include_str!("../input.txt")).unwrap();
    println!("{}", cave.clone().simulate_infinite((500, 0)));
    println!("{}", cave.simulate_floor((500, 0)));
}
