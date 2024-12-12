defmodule ProductManager do
  defprotocol Strategy do
    @doc "Calculates the cost for a product"
    def calculate(strategy)
  end

  # TODO do it carefully
  defmodule GR1Strategy do
    # TODO check if we can generaize these params
    defstruct [:price, :amount, :curency]

    defimpl Strategy do
      def calculate(%{price: price, amount: amount}) do
        min_units =
          for i <- 1..amount, rem(i, 2) != 0, reduce: 0 do
            acc -> acc + price
          end

        Float.round(min_units / 100, 2)
      end
    end
  end

  defmodule SR1Strategy do
    defstruct [:price, :amount, :curency]

    defimpl Strategy do
      def calculate(%{price: price, amount: amount}) when amount >= 3 do
        price = 450
        Float.round(amount * price / 100, 2)
      end

      def calculate(%{price: price, amount: amount}), do: amount * price
    end
  end

  defmodule CF1Strategy do
    # TODO move to protocol
    defstruct [:price, :amount, :curency]

    defimpl Strategy do
      def calculate(%{price: price, amount: amount}) when amount >= 3 do
        price = price * 0.75
        Float.round(amount * price / 100, 2)
      end

      def calculate(%{price: price, amount: amount}), do: amount * price
    end
  end
end
