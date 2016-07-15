class Query
  def initialize agency:, route_tag:
    puts "Denormalizing route #{agency} - #{route_tag}"

    Route.joins(:agency)
         .joins(directions: [direction_stops: :stop])
         .where('agencies.name' => agency)
         .where('routes.tag' => route_tag)
         .select('directions.name AS direction_name',
                 'stops.name AS stop_name',
                 'stops.coord AS coord').each do |r|
      #ap r

      printf("%8.8s | %24.24s | %24.24s\n", r[:direction_name] \
                                          , r[:stop_name]      \
                                          , r[:coord])
      # r.directions.each do |direction|
      #   ap direction.stops
      # end

    end

    Route.joins(:agency)
         .joins(:paths)
         .where('agencies.name' => agency)
         .where('routes.tag' => route_tag)
         .select('paths.coord AS path_coord').each do |r|
      puts r[:path_coord]
    end
  end
end