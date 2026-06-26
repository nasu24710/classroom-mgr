require_relative 'reservation_information'

class ReservationInformationRepository
    def initialize(reservation_informations: [])
        @reservation_informations = []

        unless reservation_informations.is_a?(Array)
            raise ArgumentError, "reservation_informations must be an Array"
        end

        replace_all(reservation_informations)
    end

    def replace_all(reservation_informations)
        reservation_informations.each do |info|
            unless info.is_a?(ReservationInformation)
                raise ArgumentError, "All elements must be instances of ReservationInformation"
            end
        end

        @reservation_informations = reservation_informations.dup
    end

    def find_all
        @reservation_informations.dup
    end
end
