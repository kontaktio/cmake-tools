# Creates library with the same syntax as command 'add_executable' but 
# adds OWN_CODE_COMPILE_FLAGS to COMPILE_FLAGS property.
function(cmtools_add_executable target_name)
    add_executable(${target_name} ${ARGN}) 
    if(DEFINED OWN_CODE_COMPILE_FLAGS)
        set_target_properties(${target_name} PROPERTIES COMPILE_FLAGS ${OWN_CODE_COMPILE_FLAGS})
    endif()
endfunction()

# Creates library with the same syntax as command 'add_library' but 
# adds OWN_CODE_COMPILE_FLAGS to COMPILE_FLAGS property.
function(cmtools_add_library target_name)
    add_library(${target_name} ${ARGN}) 
    if(DEFINED OWN_CODE_COMPILE_FLAGS)
        set_target_properties(${target_name} PROPERTIES COMPILE_FLAGS ${OWN_CODE_COMPILE_FLAGS})
    endif()
endfunction()