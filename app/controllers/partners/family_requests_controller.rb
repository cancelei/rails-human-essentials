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
        redirect_to new_partners_family_request_path, error: "Request failed! #{create_service.errors.map { |error| error.message.to_s }}}"
      end
    end
  end
end
