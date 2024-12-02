#![feature(iter_map_windows)]
#![feature(is_sorted)]

fn check(line: Vec<i32>) -> bool {
    line.is_sorted()
        && line
            .windows(2)
            .all(|x| (1..=3).contains(&(x[0] - x[1]).abs()))
}

fn main() {
    let input = include_str!("../input.txt")
        .split('\n')
        .map(|line| {
            line.split(' ')
                .filter_map(|x| x.parse::<i32>().ok())
                .collect::<Vec<_>>()
        })
        .filter(|x| !x.is_empty());

    let res1 = input
        .clone()
        .filter(|line| check(line.clone()) || check(line.iter().rev().cloned().collect::<Vec<_>>()))
        // .collect::<Vec<_>>();
        .count();

    let res2 = input
        .clone()
        .filter(|line| {
            (0..line.len()).any(|i| {
                let mut line = line.clone();
                line.remove(i);
                check(line.clone()) || check(line.iter().rev().cloned().collect::<Vec<_>>())
            })
        })
        // .collect::<Vec<_>>();
        .count();
    println!("{:#?}", res1);
    println!("{:#?}", res2);
}
