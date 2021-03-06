module Element : sig
  type t

  val t_of_js: Ojs.t -> t

  val append_child: t -> t -> unit [@@js.call]

  val set_attribute: t -> string -> string -> unit

  val set_onclick: t -> (unit -> unit) -> unit
end = [%js]

module Window : sig
  type t

  val instance: t [@@js.global "window"]

  val set_onload: t -> (unit -> unit) -> unit
end = [%js]

module Document : sig
  type t

  val instance: t [@@js.global "document"]

  val create_element: t -> string -> Element.t

  val create_text_node: t -> string -> Element.t

  val body: t -> Element.t
end = [%js]

let element tag children =
  let elt = Document.create_element Document.instance tag in
  List.iter (Element.append_child elt) children;
  elt

let textnode s = Document.create_text_node Document.instance s

let td ?colspan child =
  let elt = element "td" [child] in
  begin match colspan with
  | None -> ()
  | Some n -> Element.set_attribute elt "colspan" (string_of_int n)
  end;
  elt

let tr = element "tr"
let table = element "table"
let center x = element "center" [x]

let button x f =
  let elt = element "button" [textnode x] in
  Element.set_attribute elt "type" "button";
  Element.set_onclick elt f;
  elt

let widget () =
  let accu = ref 0. in
  let res, set_value =
    let elt = element "input" [] in
    Element.set_attribute elt "type" "text";
    Element.set_attribute elt "readonly" "";
    let set_value v = Element.set_attribute elt "value" (string_of_float v) in
    elt, set_value
  in
  set_value !accu;
  let compute = ref (fun x -> x) in
  let binop op () =
    let x = !compute !accu in
    set_value x;
    accu := 0.;
    compute := (fun y -> op x y);
  in
  let equal () =
    let x = !compute !accu in
    set_value x;
    accu := x;
    compute := (fun x -> x);
  in
  let reset () = accu := 0.; set_value !accu in
  let figure digit =
    let f () =
      accu := 10. *. !accu +. float_of_int digit;
      set_value !accu
    in
    button (string_of_int digit) f
  in
  let c l = td l in
  table [tr [td ~colspan:4 res];
         tr (List.map c [figure 7; figure 8; figure 9; button "+" (binop ( +. ))]);
         tr (List.map c [figure 4; figure 5; figure 6; button "-" (binop ( -. ))]);
         tr (List.map c [figure 1; figure 2; figure 3; button "*" (binop ( *. ))]);
         tr (List.map c [figure 0; button "C" reset; button "=" equal; button "/" (binop ( /. ))])]

let go () =
  Element.append_child (Document.body Document.instance) (center (widget()))

let () =
  Window.set_onload Window.instance go
