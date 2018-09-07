require './global_hooks.rb'

# @markup markdown
# @author FeloVilches
class Card

  attr_reader :id, :attributes, :type

  def initialize(id:, type: nil, global_hooks: nil, set_data_callback: nil, get_data_callback: nil)
    @id = id
    @type = type
    @events = Hash.new
    @attributes = Hash.new
    @pre = Hash.new
    @post = Hash.new
    @global_hooks = global_hooks

    raise ArgumentError.new("Data setter callback should have an arity of 2") if !set_data_callback.nil? && set_data_callback.arity != 2
    raise ArgumentError.new("Data getter callback should have an arity of 0") if !get_data_callback.nil? && get_data_callback.arity != 0

    @set_data_callback = set_data_callback
    @get_data_callback = get_data_callback

    on(:transfer, lambda { |args| return args.merge({ transfer: true }) })
  end


  # Triggers a custom event for this card. It executes its previously defined event handler.
  # The execution of the event handler will be preceded by the pre and post hooks.
  #
  # == Parameters:
  # event_name::
  #   A Symbol declaring the event name.
  # arguments::
  #   A Hash with any number of attributes.
  #
  # == Returns:
  # The merged Hash of every pre/post hook and the execution of the event handler itself.
  #
  def trigger_event(event:, arguments: {})

    arguments[:card] = self

    global_pre = @global_hooks.nil?? {} : @global_hooks.merge_all(:pre, event_name: event, arguments: arguments)

    scope_pre = @pre.has_key?(event)? @pre[event].call(arguments) : {}

    return false if global_pre == false || scope_pre == false

    args = {}
    args = args.merge(global_pre) if global_pre.is_a?(Hash)
    args = args.merge(scope_pre) if scope_pre.is_a?(Hash)
    args = args.merge(arguments) if arguments.is_a?(Hash)

    arguments = args

    result = {}
    result = @events[event].call(arguments) if @events.has_key?(event)

    @global_hooks.merge_all(:post, event_name: event, arguments: arguments) if !@global_hooks.nil?
    @post[event].call(arguments) if @post.has_key?(event)

    return result
  end


  # Modify the card's attributes. Useful for setting its individual state. The attributes Hash passed will be
  # merged with the previous attributes object, replacing old values, and keeping the ones that aren't included
  # in the new attributes object.
  #
  # == Parameters:
  # attrs::
  #   A Hash containing attributes and the values that will be set or replaced.
  #
  def set_attributes(attrs)
    @attributes = @attributes.merge(attrs)
  end

  def to_s
    @id
  end


  private

  # Registers an event handler for a specific event.
  #
  # == Parameters:
  # pre_post::
  #   (Optional) A Symbol declaring whether the hook is pre or post.
  # event_name::
  #   A Symbol declaring the event name.
  # call_back::
  #   A lambda function or a class method symbol that gets executed whenever the event is triggered. This function can receive parameters.
  #
  def on(*args)

    if args.length == 3
      return set_hook(*args)
    end

    event_name = args[0]
    call_back = args[1]
    function = nil

    if call_back.respond_to? :call
      function = call_back
    else
      function = method(call_back)
    end

    raise ArgumentError.new("Event handlers need to have one argument") if function.arity != 1

    @events[event_name] = function

  end


  def set_data(action:, arguments: {})
    return if @set_data_callback.nil?
    @set_data_callback.call(action, arguments)
  end

  def get_data
    return @get_data_callback.call if !@get_data_callback.nil?
    return nil
  end


  def set_hook(pre_post, event_name, call_back)
    call_back = method(call_back) if !call_back.respond_to? :call
    hook_hash = (pre_post == :pre)? @pre : @post

    raise ArgumentError.new("Pre and post hooks need to have one argument") if call_back.arity != 1

    hook_hash[:transfer] = call_back
    hook_hash.delete :transfer if call_back.nil?
  end


end
