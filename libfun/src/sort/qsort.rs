pub fn quicksort<T: Ord>(slice: &mut [T]) {
    let last: usize = slice.len() - 1;
    q_sort(slice, 0, last);
}

fn q_sort<T: Ord>(slice: &mut [T], left: usize, right: usize) {
    let mut l = left;
    let mut r = right;

    let p1_i = left;
    let p2_i = (left + right) / 2;
    let p3_i = right;
    let mut pivot_i = if slice[p1_i] < slice[p2_i] {
            if slice[p3_i] < slice[p2_i] {
                if slice[p1_i] < slice[p3_i] {
                    p3_i
                }else{
                    p1_i
                }
            }else{
                p2_i
            }
        }else{ // slice[p2_i] <= slice[p1_i]
            if slice[p3_i] < slice[p1_i] {
                if slice[p2_i] < slice[p3_i] {
                    p3_i
                }else{
                    p2_i
                }
            }else{
                p1_i
            }
        };

    while l < r {
        while (slice[pivot_i] < slice[r]) && (l < r) {
            r = r - 1;
        }
        if l != r {
            slice.swap(pivot_i, r);
            pivot_i = r;
        }
        while (slice[l] < slice[pivot_i]) && (l < r) {
            l = l + 1;
        }
        if l != r {
            slice.swap(pivot_i, l);
            pivot_i = l;
        }
    }
    if left < l {
        q_sort(slice, left, l - 1);
    }
    if right > l {
        q_sort(slice, l + 1, right);
    }
}



pub fn test() {
    let mut numbers = [5, 3, 1, 6, 8, 4, 7, 2];
    quicksort(&mut numbers);
    assert_eq!([1, 2, 3, 4, 5, 6, 7, 8], numbers); 

    println!("{:?}", numbers);
}


