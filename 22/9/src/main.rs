use std::collections::HashSet;

#[derive(Clone, Debug)]
struct Player {
    x: i32,
    y: i32,
}

#[derive(Clone, Debug)]
struct Grid {
    head: Player,
    tails: Vec<Player>,
    stores: Vec<HashSet<Vec<i32>>>,
}

impl Grid {
    fn do_move(&mut self, dir: char, amount: i32) -> &mut Grid {
        for _ in 0..amount {
            match dir {
                'R' => self.head.x += 1,
                'L' => self.head.x -= 1,
                'U' => self.head.y += 1,
                'D' => self.head.y -= 1,
                _ => {}
            }
            self.move_tails();
            self.stores.iter_mut().enumerate().for_each(|(i, ele)| {
                ele.insert(vec![self.tails[i].x, self.tails[i].y]);
            });
        }
        return self;
    }

    fn move_tail_with_prev(&mut self, idx: usize, head: Player) -> &mut Grid {
        let mut tail: &mut Player = &mut self.tails[idx];
        return match ((head.x - tail.x).abs(), (head.y - tail.y).abs()) {
            (0, 0) | (0, 1) | (1, 0) | (1, 1) => self,
            (0..=1, _) => {
                tail.x = head.x;
                tail.y += ((head.y > tail.y) as i32) * 2 - 1;
                self
            }
            (_, 0..=1) => {
                tail.x += ((head.x > tail.x) as i32) * 2 - 1;
                tail.y = head.y;
                self
            }
            (a, b) if a == b => {
                tail.x = if head.x > tail.x {
                    head.x - 1
                } else {
                    head.x + 1
                };
                tail.y = if head.y > tail.y {
                    head.y - 1
                } else {
                    head.y + 1
                };
                // tail.x += ((head.x > tail.x) as i32) * 2 - 1;
                // tail.y += ((head.y > tail.y) as i32) * 2 - 1;
                self
            }
            (_, _) => self,
        };
    }

    fn move_tails(&mut self) -> &mut Grid {
        for i in 0..self.tails.len() {
            let prev = if i == 0 {
                self.head.clone()
            } else {
                self.tails[i - 1].clone()
            };
            self.move_tail_with_prev(i, prev);
        }
        self
    }
}

fn main() {
    let x = include_str!("../input.txt")
        .lines()
        .map(|line| line.split_whitespace().collect::<Vec<_>>())
        .collect::<Vec<_>>();
    let mut moves = vec![];
    for line in x {
        moves.push((line[0], line[1].parse::<i32>().unwrap()));
    }
    let mut grid = Grid {
        head: Player { x: 0, y: 0 },
        tails: vec![Player { x: 0, y: 0 }; 9],
        stores: vec![HashSet::new(); 9],
    };

    for (dir, amount) in moves {
        grid.do_move(dir.chars().nth(0).unwrap(), amount);
    }
    println!("{}", grid.stores[0].len());
    println!("{:?}", grid.stores.last().unwrap().len())
}
