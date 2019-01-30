use crate::rpds::List;


pub fn test() {

    let list = List::new().push_front("list");

    assert_eq!(list.first(), Some(&"list"));

    let a_list = list.push_front("a");

    assert_eq!(a_list.first(), Some(&"a"));

    let list_dropped = a_list.drop_first().unwrap();

    assert_eq!(list_dropped, list);
}