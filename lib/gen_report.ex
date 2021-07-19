defmodule GenReport do
  @moduledoc """
    This module provides a function to generate a report of worked hours per person, per month and per year
    in a company
  """

  @months [
    "janeiro",
    "fevereiro",
    "março",
    "abril",
    "maio",
    "junho",
    "julho",
    "agosto",
    "setembro",
    "outubro",
    "novembro",
    "dezembro"
  ]

  @people [
    "cleiton",
    "daniele",
    "danilo",
    "diego",
    "giuliano",
    "jakeliny",
    "joseph",
    "mayk",
    "rafael",
    "vinicius"
  ]

  @years [
    2016,
    2017,
    2018,
    2019,
    2020
  ]

  alias GenReport.Parser

  @doc """
    Builds a report of worked hours per person, per month and per year

    ## Parameters
    - filename: A CSV file name with the worked time data\n

    ## Examples
        iex> GenReport.build("gen_report.csv")
        %{
          "all_hours" => %{...},
          "hours_per_month" => %{...},
          "hours_per_year" => %{...}
        }
  """
  @spec build(charlist) :: map
  def build(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.reduce(
      report_accumulator(),
      fn person_data, report -> update_report_data(person_data, report) end
    )
  end

  @spec build :: {:error, <<_::216>>}
  def build, do: {:error, "Insira o nome de um arquivo"}

  defp update_report_data(
         [name, hours, _day, month, year],
         %{
           "all_hours" => all_hours,
           "hours_per_month" => month_hours,
           "hours_per_year" => year_hours
         } = report
       ) do
    all_hours = Map.put(all_hours, name, all_hours[name] + hours)

    person_month_hours = Map.put(month_hours[name], month, month_hours[name][month] + hours)

    person_year_hours = Map.put(year_hours[name], year, year_hours[name][year] + hours)

    %{
      report
      | "all_hours" => all_hours,
        "hours_per_month" => %{month_hours | name => person_month_hours},
        "hours_per_year" => %{year_hours | name => person_year_hours}
    }
  end

  defp report_accumulator do
    %{
      "all_hours" => generate_all_hours_map(),
      "hours_per_month" => generate_hours_per_month_map(),
      "hours_per_year" => generate_hours_per_year_map()
    }
  end

  defp generate_all_hours_map do
    @people
    |> Enum.into(%{}, fn elem -> {elem, 0} end)
  end

  defp generate_hours_per_month_map do
    @people
    |> Enum.into(%{}, fn elem -> {elem, create_month_hours()} end)
  end

  defp generate_hours_per_year_map do
    @people
    |> Enum.into(%{}, fn elem -> {elem, create_year_hours()} end)
  end

  defp create_year_hours do
    @years
    |> Enum.into(%{}, fn elem -> {elem, 0} end)
  end

  defp create_month_hours do
    @months
    |> Enum.into(%{}, fn elem -> {elem, 0} end)
  end
end
