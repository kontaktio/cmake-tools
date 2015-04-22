# Creates library with the same syntax as command 'add_executable' but 
# adds KT_OWN_CODE_COMPILE_FLAGS to COMPILE_FLAGS property.
# use --warn-uninitialized to warn when used with KT_OWN_CODE_COMPILE_FLAGS undefined
function(cmtools_add_executable target_name)
    add_executable(${target_name} ${ARGN}) 
    set_target_properties(${target_name} PROPERTIES COMPILE_FLAGS ${KT_OWN_CODE_COMPILE_FLAGS})
endfunction()

# Creates library with the same syntax as command 'add_library' but 
# adds KT_OWN_CODE_COMPILE_FLAGS to COMPILE_FLAGS property.
# use --warn-uninitialized to warn when used with KT_OWN_CODE_COMPILE_FLAGS undefined
function(cmtools_add_library target_name)
    add_library(${target_name} ${ARGN}) 
    set_target_properties(${target_name} PROPERTIES COMPILE_FLAGS ${KT_OWN_CODE_COMPILE_FLAGS})
endfunction()