module AdminHelper

  def active_link(target_controller_name, action_name)
    if controller.controller_name == target_controller_name
      return 'active' if controller.action_name == action_name
    end
  end

end
