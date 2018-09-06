require 'rydux'
require './card.rb'

class UserReducer < Rydux::Reducer

  # Your reducer MUST have a map_state function in order to do anything.
  def self.map_state(action, state = {})
    case action[:type]
    when 'SOME_RANDOM_ACTION' # You can add as many actions here as you'd like
      state.merge(some_random_data: true)
    when 'APPEND_PAYLOAD'
      state.merge(action[:payload])
    else
      state
    end
  end

end


Store = Rydux::Store.new(user: UserReducer)

Store.dispatch(type: 'CHANGE_USER_NAME', payload: { name: 'Mike' })
Store.dispatch(type: 'SOME_RANDOM_ACTION')




puts Store.state.user
