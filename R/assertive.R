# the point of this file is to create empty functions 
# corresponding to names in the assertive package.
# if the assertive package becomes available again 
# these functions will be removed

# assertive.numbers 


invisible(mapply(function(xx) assign(xx, function(...){}, pos=1), 
	xx = 
		c( paste0('assert_', 
			c('all_are_in_closed_range', 'assert_all_are_positive', 'all_are_in_range(')),

#assertive.types 

		paste0('assert_is_', c('scalar', 'matrix', 'numeric', 'a_bool', 'a_number')),


# assertive.properties

		'assert_is_of_length',

# assertive.base
		c('get_name_in_parent', 'assert_engine', 'assert_all_are_true')
	)

))