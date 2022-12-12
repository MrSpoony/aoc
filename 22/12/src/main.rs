use std::collections::VecDeque;

type Point = (usize, usize);

struct Grid {
    width: usize,
    start: Point,
    _starts: Vec<Point>,
    end: Point,
    height: usize,
    grid: Vec<Vec<char>>,
}

impl Grid {
    fn new(s: &str) -> Grid {
        let lines = s.lines().collect::<Vec<_>>();
        let width = lines[0].len();
        let height = lines.len();
        let mut grid = lines
            .into_iter()
            .map(|line| line.chars().collect::<Vec<_>>())
            .collect::<Vec<_>>();
        let mut start = (0, 0);
        let mut end = (0, 0);
        for (i, line) in grid.iter().enumerate() {
            for (j, &c) in line.iter().enumerate() {
                if c == 'S' {
                    start = (i, j);
                } else if c == 'E' {
                    end = (i, j);
                }
            }
        }
        grid.iter_mut().for_each(|line| {
            line.iter_mut().for_each(|c| {
                if *c == 'S' {
                    *c = 'a';
                } else if *c == 'E' {
                    *c = 'z';
                }
            })
        });
        let starts = grid
            .iter()
            .enumerate()
            .map(|(i, line)| {
                line.iter()
                    .enumerate()
                    .filter_map(|(j, c)| if *c == 'a' { Some((i, j)) } else { None })
                    .collect::<Vec<Point>>()
            })
            .flatten()
            .collect::<Vec<_>>();
        return Grid {
            width,
            height,
            grid,
            start,
            end,
            _starts: starts,
        };
    }

    fn get_shortest_path_from_start(&self, start: Option<Point>) -> usize {
        let mut queue = VecDeque::new();
        queue.push_back((start.unwrap_or(self.start), 0));
        let mut visited: Vec<Vec<bool>> = vec![vec![false; self.width]; self.height];
        while !queue.is_empty() {
            let ((i, j), res) = queue.pop_front().unwrap();
            let curr = self.grid[i][j] as i32;
            match (i, j) {
                (i, j) if visited[i][j] => continue,
                (i, j) if (i, j) == self.end => {
                    return res;
                }
                (i, j) => {
                    if i > 0 && self.grid[i - 1][j] as i32 - curr <= 1 {
                        queue.push_back(((i - 1, j), res + 1));
                    };
                    if i < self.grid.len() - 1 && self.grid[i + 1][j] as i32 - curr <= 1 {
                        queue.push_back(((i + 1, j), res + 1));
                    };
                    if j > 0 && self.grid[i][j - 1] as i32 - curr <= 1 {
                        queue.push_back(((i, j - 1), res + 1));
                    };
                    if j < self.grid[0].len() - 1 && self.grid[i][j + 1] as i32 - curr <= 1 {
                        queue.push_back(((i, j + 1), res + 1));
                    };
                }
            }
            visited[i][j] = true;
        }
        return std::usize::MAX;
    }

    fn get_shortest_path_from_end(&self) -> usize {
        let mut queue = VecDeque::new();
        queue.push_back((self.end, 0));
        let mut visited: Vec<Vec<bool>> = vec![vec![false; self.width]; self.height];
        while !queue.is_empty() {
            let ((i, j), res) = queue.pop_front().unwrap();
            let curr = self.grid[i][j] as i32;
            match (i, j) {
                (i, j) if visited[i][j] => continue,
                (i, j) if self.grid[i][j] == 'a' => {
                    return res;
                }
                (i, j) => {
                    if i > 0 && curr - self.grid[i - 1][j] as i32 <= 1 {
                        queue.push_back(((i - 1, j), res + 1));
                    };
                    if i < self.grid.len() - 1 && curr - self.grid[i + 1][j] as i32 <= 1 {
                        queue.push_back(((i + 1, j), res + 1));
                    };
                    if j > 0 && curr - self.grid[i][j - 1] as i32 <= 1 {
                        queue.push_back(((i, j - 1), res + 1));
                    };
                    if j < self.grid[0].len() - 1 && curr - self.grid[i][j + 1] as i32 <= 1 {
                        queue.push_back(((i, j + 1), res + 1));
                    };
                }
            }
            visited[i][j] = true;
        }
        return std::usize::MAX;
    }

    fn _get_shortest_path(&self) -> usize {
        let mut res = std::usize::MAX;
        for start in self._starts.iter() {
            let x = self.get_shortest_path_from_start(Some(*start));
            res = res.min(x);
        }
        return res;
    }
}

fn main() {
    let grid = Grid::new(include_str!("../input.txt"));
    println!("{}", grid.get_shortest_path_from_start(None));
    println!("{}", grid.get_shortest_path_from_end());
}
