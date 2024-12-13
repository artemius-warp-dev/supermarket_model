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

      def calculate(%{price: price, amount: amount}), do: Float.round(amount * price / 100, 2)
    end
  end

  defmodule CF1Strategy do
    # TODO move to protocol
    defstruct [:price, :amount, :curency]

    defimpl Strategy do
      def calculate(%{price: price, amount: amount}) when amount >= 3 do
        price = Float.round(price / 3 * 2, 2)
        Float.round(amount * price / 100, 2)
      end

      def calculate(%{price: price, amount: amount}), do: Float.round(amount * price / 100, 2)
    end
  end



    # TODO do it carefully
  defmodule GR1TestStrategy do
    # TODO check if we can generaize these params
    defstruct [:price, :amount, :curency]

    defimpl Strategy do
      def calculate(%{price: price, amount: amount}) do
        IO.inspect({"GR1TestStrategy", amount})
        min_units =
          for i <- 1..amount, rem(i, 2) != 0, reduce: 0 do
            acc ->
              Process.sleep(10)
              acc + price
          end
        
        Float.round(min_units / 100, 2)
      end
    end
  end

  defmodule SR1TestStrategy do
    defstruct [:price, :amount, :curency]

    defimpl Strategy do
      def calculate(%{price: price, amount: amount}) when amount >= 3 do
        price = 450
        Process.sleep(1000)
        Float.round(amount * price / 100, 2)
      end

      def calculate(%{price: price, amount: amount}), do: Float.round(amount * price / 100, 2)
    end
  end

  defmodule CF1TestStrategy do
    # TODO move to protocol
    defstruct [:price, :amount, :curency]

    defimpl Strategy do
      def calculate(%{price: price, amount: amount}) when amount >= 3 do
        
        price = Float.round(price / 3 * 2, 2)
        Process.sleep(1000)
        Float.round(amount * price / 100, 2)
      end

      def calculate(%{price: price, amount: amount}), do: Float.round(amount * price / 100, 2)
    end
  end


  
  
end
