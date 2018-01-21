(*stores game properties*)
type gp = {x_size: int; y_size:int}
(*stores bar*)
type bar = {x:int; y:int; height: int; width: int}
type ball = {x:int; y:int; r:int; angle: float}

(*quit message*)
let quit_game text gp = 
  Graphics.clear_graph ();
  Graphics.set_color Graphics.black;
  Graphics.fill_rect 1 1 gp.x_size gp.y_size;
  Graphics.set_color Graphics.white;
  Graphics.moveto 300 300;
  Graphics.set_text_size 20;
  Graphics.draw_string text;
  Graphics.synchronize ();
  Unix.sleepf 2.0;
  exit 0;;

(*draws bars and ball*)
let update_gui gp (first:bar) (second:bar) (ball:ball)=
  Graphics.auto_synchronize false;
  Graphics.clear_graph ();
  Graphics.set_color Graphics.black;
  Graphics.fill_rect 1 1 gp.x_size gp.y_size;
  Graphics.set_color Graphics.green;
  Graphics.fill_rect first.x first.y first.width first.height; 
  Graphics.fill_rect second.x second.y second.width second.height;
  Graphics.set_color Graphics.red;
  Graphics.fill_circle ball.x ball.y ball.r;
  Graphics.synchronize ();; 


let move_bar (bar:bar) diff gp =
  let module G = Graphics in
  if G.key_pressed () then
    let key = G.read_key () in
    if key = 'd' then
      if bar.x+bar.width+diff>gp.x_size then bar
      else {bar with x=bar.x+diff}
    else if key='a' then
      if bar.x-diff<0 then bar
      else {bar with x=bar.x-diff}
    else bar
  else bar;;


(*Move CPU bar with following x pos of ball*)
let move_cpu (bar:bar) diff gp (ball:ball)= 
  if ball.angle>=180.0 then
    bar
  else
    let key =(if ball.x>bar.x+bar.width-bar.width/5 then 'd' else if ball.x<bar.x+bar.width/5 then 'a' else 'k') in
    if key = 'd' then
      if bar.x+bar.width+diff>gp.x_size then bar
      else {bar with x=bar.x+diff}
    else if key='a' then
      if bar.x-diff<0 then bar
      else {bar with x=bar.x-diff}
    else bar;;

(*returns a new angle depending on position of impact on bar*)
let new_angle angle width pos = 
  if angle >=180.0 then 190.0 +. ( (float_of_int width) -. (float_of_int pos) )/.(float_of_int width)*.160.0
  else ((float_of_int width) -. (float_of_int pos))/.(float_of_int width)*.160.0 +. 10.
       
(*propagates balls, considers reflections and decides if someone lost*)
let move_ball {x;y;r;angle} diff (bar1:bar) (bar2:bar) gp = 
  let x_new = x + (((float_of_int diff)*.(cos (angle*.2.0*.3.1415/.360.0))) |> int_of_float)  in 
  let y_new = y + (((float_of_int diff)*.(sin (angle*.2.0*.3.1415/.360.0))) |> int_of_float)  in
  if y_new <= bar1.height then
    if bar1.x-2<=x && x<=bar1.x+bar1.width+2 then
      {x=x_new;y=y_new+5; r=r; angle=new_angle (360.0-.angle) bar1.width (x-bar1.x) }
    else quit_game "You loose!" gp
  else if y_new >= gp.y_size-bar1.height then
    if bar2.x-2<=x && x<=bar2.x+bar2.width+2 then
      {x=x_new;y=y_new-5; r=r; angle=360.0-.(new_angle angle bar2.width (x-bar2.x))}
    else quit_game "You win!" gp
  else if x_new<=0 then {x=x+2; y=y; r=r; 
                    angle=if angle>=90.0 && angle <=180.0 then 180.0-.angle 
                          else if 270.0>=angle && angle>=180.0 then 540.0-.angle
                          else angle}
  else if x_new >=gp.x_size then {x=x-2; y=y; r=r; 
                          angle=if angle>=0.0 && angle <=90.0 then 180.0-.angle 
                          else if 360.0>=angle && angle>=270.0 then 540.0-.angle
                          else angle} 
  else {x=x_new; y=y_new; r=r; angle=angle};;


(*game manager*)
let rec game gp =
  (*turns off refresh*)
  Graphics.auto_synchronize false;
  let open Graphics in
  let () = open_graph (" "^(string_of_int gp.x_size)^"x"^(string_of_int gp.y_size)) in
  let bar2 = {x=300; y= 800-20; width=100; height=20} in
  let bar1 = {x=300; y=2; width=100; height=20} in
  let ball = {x=200; y=200; r=10; angle=90.0} in
  update_gui gp bar1 bar2 ball;
  (*main loo*)
  let rec main bar1 bar2 ball =
    let bar1 = move_bar bar1 8 gp  in
    let bar2 = move_cpu bar2 8 gp ball in
    let ball = move_ball ball 10 bar1 bar2 gp in
    update_gui gp bar1 bar2 ball;
    Unix.sleepf 0.02; 
    main bar1 bar2 ball in
  main bar1 bar2 ball;;
  
let () = game ({x_size=800; y_size=800})
