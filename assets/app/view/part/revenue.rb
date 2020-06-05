# frozen_string_literal: true

require 'view/part/base'
require 'view/part/multi_revenue'

module View
  module Part
    class Revenue < Base
      P_RIGHT_CORNER = {
        region_weights_in: LEFT_CORNER + LEFT_MID,
        region_weights_out: LEFT_CORNER,
        x: 75,
        y: 0,
      }.freeze

      def preferred_render_locations
        if multi_revenue?
          [
            {
              region_weights: CENTER,
              x: 0,
              y: 0,
            },
            {
              region_weights: TOP_MIDDLE_ROW,
              x: 0,
              y: -24,
            },
            {
              region_weights: BOTTOM_MIDDLE_ROW,
              x: 0,
              y: 24,
            },
            {
              region_weights: TOP_ROW,
              x: 0,
              y: -48,
            },
            {
              region_weights: BOTTOM_ROW,
              x: 0,
              y: 48,
            },
          ]
        else
          [P_RIGHT_CORNER]
        end
      end

      def load_from_tile
        @slots = @tile.cities.map(&:slots).sum + @tile.towns.size
        @cities = @tile.cities.size
        stops = @tile.stops
        @hide = stops.any?(&:hide)

        revenues = stops.map(&:revenue).uniq

        return if @hide || revenues.empty?

        if revenues.one?
          revenues = revenues.first
        else
          puts "WARNING: encountered multiple different revenues on tile #{@tile.name}"
          @revenue = nil
          return
        end

        @revenue =
          if revenues.values.uniq.one?
            revenues.values.first
          else
            revenues
          end
      end

      def should_render?
        ![nil, 0].include?(@revenue)
      end

      def multi_revenue?
        !@revenue.is_a?(Numeric)
      end

      def render_part
        transform = "#{translate} #{rotation_for_layout}"

        if multi_revenue?
          h(Part::MultiRevenue, revenues: @revenue, transform: transform)
        else
          h(Part::SingleRevenue, revenue: @revenue, transform: transform)
        end
      end
    end
  end
end
