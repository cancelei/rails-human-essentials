module Partners
  class FamilyRequestsController < BaseController
    before_action :verify_partner_is_active
    before_action :authorize_verified_partners

    def new
      @filterrific = initialize_filterrific(
        current_partner.children
                       .order(last_name: :asc)
                       .order(first_name: :asc),
        params[:filterrific]
      ) || return
      @children = @filterrific.find

      @children_items = flash[:children_items] || {}
      @error_messages = flash[:error_messages]
    end

    def create
      children_items = params[:children_items] || {} # Assuming this is how you structured the data
      family_requests_attributes = []

      children_items.each do |child_id, item_ids|
        child = current_partner.children.active.find_by(id: child_id)
        next unless child

        item_ids.each do |item_id|
          # Assuming each item can be requested once per child in a request
          family_requests_attributes << { item_id: item_id, person_count: 1, child: child }
        end
      end

      create_service = Partners::FamilyRequestCreateService.new(
        partner_user_id: current_user.id,
        family_requests_attributes: family_requests_attributes,
        for_families: true
      )

      create_service.call

      if create_service.errors.none?
        redirect_to partners_request_path(create_service.partner_request), notice: "Requested items successfully!"
      else
        # Save the original request data in the flash to repopulate the form upon redirection
        flash[:children_items] = children_items
        flash[:error_messages] = create_service.errors.full_messages.join(", ")
        redirect_to new_partners_family_request_path
      end
    end
  end
end
