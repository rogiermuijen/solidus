# frozen_string_literal: true

module Spree
  class DistributedAmountsHandler
    attr_reader :line_items, :total_amount

    def initialize(line_items, total_amount)
      @line_items = line_items
      @total_amount = total_amount
    end

    # @param [LineItem] one of the line_items distributed over
    # @return [BigDecimal] the weighted adjustment for this line_item
    def amount(line_item)
      distributed_amounts[line_item.id].to_d
    end

    private

    # @private
    # @return [Hash<Integer, BigDecimal>] a hash of line item IDs and their
    #   corresponding weighted adjustments
    def distributed_amounts
      Hash[line_item_ids.zip(allocated_amounts)]
    end

    def line_item_ids
      line_items.map(&:id)
    end

    def elligible_amounts
      line_items.map(&:amount)
    end

    def subtotal
      elligible_amounts.sum
    end

    def weights
      elligible_amounts.map { |amount| amount.to_f / subtotal.to_f }
    end

    def allocated_amounts
      total_amount.to_money.allocate(weights).map(&:to_money)
    end
  end
end
