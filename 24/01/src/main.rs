use std::{collections::HashMap, iter::zip};

fn main() {
    let (mut l, mut r): (Vec<_>, Vec<_>) = include_str!("../input.txt")
        .split('\n')
        .filter_map(|val| {
            let x = val
                .split(' ')
                .filter_map(|x| x.parse::<i32>().ok())
                .collect::<Vec<_>>();
            if x.len() == 2 {
                Some((x[0], x[1]))
            } else {
                None
            }
        })
        .unzip();
    // sort l and r
    l.sort_unstable();
    r.sort_unstable();
    let res1 = zip(l.clone(), r.clone()).fold(0, |acc, (l, r)| acc + (l - r).abs());
    println!("{}", res1);

    let map = r.iter().fold(HashMap::new(), |mut acc, x| {
        acc.entry(x).and_modify(|e| *e += 1).or_insert(1);
        acc
    });
    let res2 = l.iter().map(|x| x * map.get(&x).unwrap_or(&0)).sum::<i32>();
    println!("{}", res2);
}
