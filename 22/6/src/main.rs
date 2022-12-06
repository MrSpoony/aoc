use std::collections::HashSet;

fn main() {
    let text = include_str!("../input.txt").chars();
    for (i, _) in text.clone().enumerate() {
        let mut set: HashSet<char> = HashSet::new();
        let mut possible = true;
        for j in i..(i + 14) {
            if set.contains(&text.clone().nth(j).unwrap()) {
                possible = false;
                break;
            }
            set.insert(text.clone().nth(j).unwrap());
        }
        if possible {
            println!("{}", i + 14);
            break;
        }
    }
}
