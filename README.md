# Bowling game API

#How to run app locally
- clone this repo
- navigate to this repo folder
- run rake db:migrate
- start rails server using rails s

#API end points
 - POST api/v1/create (to create new game)
 - PUT api/v1/roll_ball , payload is { game_id: game_id, knocked_pins: number_of_pins } 
 - GET api/v1/score , params is { game_id: game_id }
