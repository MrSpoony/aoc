use std::collections::{HashMap, HashSet};

enum Dir {
    Left,
    Right,
}

type Point = (i32, i32);

#[derive(Debug)]
struct Board {
    cells: HashSet<Point>,
    top: i32,
    time: i32,
    jet: String,
}

impl Board {
    fn get_jet(&self) -> Dir {
        match self
            .jet
            .chars()
            .nth((self.time % self.jet.len() as i32) as usize)
            .unwrap()
        {
            '<' => Dir::Left,
            '>' => Dir::Right,
            _ => unreachable!(),
        }
    }
}

fn main() {
    let pieces: Vec<HashSet<Point>> = vec![
        HashSet::from([(0, 0), (1, 0), (2, 0), (3, 0)]),
        HashSet::from([(1, 0), (0, 1), (1, 1), (2, 1), (2, 1)]),
        HashSet::from([(2, 0), (2, 1), (2, 2), (0, 2), (1, 2)]),
        HashSet::from([(0, 0), (0, 1), (0, 2), (0, 3)]),
        HashSet::from([(0, 0), (0, 1), (1, 0), (1, 1)]),
    ];
    let mut board = Board {
        cells: HashSet::new(),
        top: 0,
        time: 0,
        jet: String::from(include_str!("../input_test.txt")),
    };
    for i in 0..2022 {
        let piece = pieces[(board.time % 5) as usize].clone();
        let bot = piece
            .iter()
            .reduce(|a, b| if a.1 > b.1 { a } else { b })
            .unwrap()
            .1;
    }
}
