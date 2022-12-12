fn main() {
    let x = include_str!("../input.txt")
        .lines()
        .map(|line| {
            line.chars()
                .map(|c| c.to_digit(10).unwrap() as i32)
                .collect::<Vec<_>>()
        })
        .collect::<Vec<_>>();
    let mut grid = vec![vec![false; x[0].len()]; x.len()];
    for i in 0..x.len() {
        let mut acc: i32 = -1;
        for j in 0..x[0].len() {
            grid[i][j] = grid[i][j] || acc < x[i][j].into();
            acc = acc.max(x[i][j]);
        }
        acc = -1;
        for j in (0..x[0].len()).rev() {
            grid[i][j] = grid[i][j] || acc < x[i][j].into();
            acc = acc.max(x[i][j]);
        }
        acc = -1;
        for j in 0..x[0].len() {
            grid[j][i] = grid[j][i] || acc < x[j][i].into();
            acc = acc.max(x[j][i]);
        }
        acc = -1;
        for j in (0..x[0].len()).rev() {
            grid[j][i] = grid[j][i] || acc < x[j][i].into();
            acc = acc.max(x[j][i]);
        }
    }
    println!(
        "{}",
        grid.iter()
            .map(|line| line.iter().filter(|x| **x).count())
            .sum::<usize>()
    );
    let mut maxi = 0;
    for i in 0..x.len() {
        for j in 0..x[0].len() {
            maxi = maxi.max(calculate_for_tree(i, j, &x));
        }
    }
    println!("{}", maxi);
}

fn calculate_for_tree(x: usize, y: usize, grid: &Vec<Vec<i32>>) -> i32 {
    let this = grid[y][x];
    let mut count = 1;
    let mut cnt = 0;
    // up
    for i in (0..y).rev() {
        cnt += 1;
        if grid[i][x] >= this {
            break;
        }
    }
    count *= cnt;
    cnt = 0;
    // left
    for i in (0..x).rev() {
        cnt += 1;
        if grid[y][i] >= this {
            break;
        }
    }
    count *= cnt;
    cnt = 0;
    // down
    for i in (y + 1)..grid.len() {
        cnt += 1;
        if grid[i][x] >= this {
            break;
        }
    }
    count *= cnt;
    cnt = 0;
    // right
    for i in (x + 1)..grid[0].len() {
        cnt += 1;
        if grid[y][i] >= this {
            break;
        }
    }
    count *= cnt;
    return count;
}
