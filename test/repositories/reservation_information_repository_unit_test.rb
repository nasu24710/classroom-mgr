require_relative '../test_helper'
require_relative '../../lib/reservation_information_repository'
require_relative '../../lib/reservation_information'

class ReservationInformationRepositoryTest < Minitest::Test
    def setup
        @reservation_a = ReservationInformation.new(
            date: Date.new(2024, 6, 1),
            subject: 'Mathematics',
            periods: [:p1, :p2],
            user: 'John Doe',
            room_names: ['Room A']
        )

        @reservation_b = ReservationInformation.new(
            date: Date.new(2024, 6, 2),
            subject: 'Physics',
            periods: [:p3],
            user: 'Jane Doe',
            room_names: ['Room B']
        )
    end

    def test_initialize_and_find_all
        repository = ReservationInformationRepository.new(
            reservation_informations: [@reservation_a]
        )

        assert_equal [@reservation_a], repository.find_all
    end

    def test_find_all_returns_copy
        repository = ReservationInformationRepository.new(
            reservation_informations: [@reservation_a]
        )

        result = repository.find_all
        result << @reservation_b

        assert_equal [@reservation_a], repository.find_all
    end

    def test_replace_all
        repository = ReservationInformationRepository.new
        repository.replace_all([@reservation_a])

        assert_equal [@reservation_a], repository.find_all
    end

    def test_invalid_initialization_argument
        assert_raises(TypeError) do
            ReservationInformationRepository.new(reservation_informations: 'not an array')
        end
    end

    def test_replace_all_with_empty_array
        repository = ReservationInformationRepository.new(reservation_informations: [@reservation_a])
        repository.replace_all([])

        assert_equal [], repository.find_all
    end

    def test_invalid_replace_all_argument
        repository = ReservationInformationRepository.new

        assert_raises(TypeError) do
            repository.replace_all('not an array')
        end
    end
end
