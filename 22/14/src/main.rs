use std::{collections::HashSet, str::FromStr};

#[derive(Debug)]
struct Cave {
    map: HashSet<(i32, i32)>,
}

impl FromStr for Cave {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let mut cave = Cave {
            map: HashSet::new(),
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
        return Ok(cave);
    }
}

impl Cave {
    fn simulate(&mut self, start: (i32, i32)) -> usize {
        let mut res = 0;
        while self.drop_one(start) {
            res += 1;
        }
        res
    }

    fn drop_one(&mut self, start: (i32, i32)) -> bool {
        let mut curr = start;
        'outer: loop {
            if curr.1 >= 1000 {
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
}

fn main() {
    let mut cave = Cave::from_str(include_str!("../input.txt")).unwrap();
    println!("{}", cave.simulate((500, 0)));
}
