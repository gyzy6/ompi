# -*- shell-script -*-
#
# Copyright (c) 2004-2005 The Trustees of Indiana University and Indiana
#                         University Research and Technology
#                         Corporation.  All rights reserved.
# Copyright (c) 2004-2005 The University of Tennessee and The University
#                         of Tennessee Research Foundation.  All rights
#                         reserved.
# Copyright (c) 2004-2005 High Performance Computing Center Stuttgart, 
#                         University of Stuttgart.  All rights reserved.
# Copyright (c) 2004-2006 The Regents of the University of California.
#                         All rights reserved.
# Copyright (c) 2009      Cisco Systems, Inc.  All rights reserved.
# Copyright (c) 2008-2011 University of Houston. All rights reserved.
# $COPYRIGHT$
# 
# Additional copyrights may follow
# 
# $HEADER$
#

# OMPI_CHECK_PVFS2(prefix, [action-if-found], [action-if-not-found])
# --------------------------------------------------------
# check if PVFS2 support can be found.  sets prefix_{CPPFLAGS, 
# LDFLAGS, LIBS} as needed and runs action-if-found if there is
# support, otherwise executes action-if-not-found
AC_DEFUN([OMPI_CHECK_PVFS2],[

    check_pvfs2_CPPFLAGS=
    check_pvfs2_LDFLAGS=
    check_pvfs2_LIBS=

    check_pvfs2_save_wrapper_extra_libs="$WRAPPER_EXTRA_LIBS"
    check_pvfs2_save_wrapper_extra_ldflags="$WRAPPER_EXTRA_LDFLAGS"
    check_pvfs2_save_wrapper_extra_cflags="$WRAPPER_EXTRA_CFLAGS"
    check_pvfs2_save_wrapper_extra_cppflags="$WRAPPER_EXTRA_CPPFLAGS"
    check_pvfs2_save_LIBS="$LIBS" 
    check_pvfs2_save_LDFLAGS="$LDFLAGS"
    check_pvfs2_save_CFLAGS="$CFLAGS"
    check_pvfs2_save_CPPFLAGS="$CPPFLAGS"

    check_pvfs2_configuration="none"
    ompi_check_pvfs2_happy="yes"


    # Get some configuration information
    AC_ARG_WITH([pvfs2],
        [AC_HELP_STRING([--with-pvfs2(=DIR)],
             [Build Pvfs2 support, optionally adding DIR/include, DIR/lib, and DIR/lib64 to the search path for headers and libraries])])
    OMPI_CHECK_WITHDIR([pvfs2], [$with_pvfs2], [include/pvfs2.h])

    AC_ARG_WITH([pvfs2-libs], 
        [AC_HELP_STRING([--with-pvfs2-libs=LIBS],
                       [Libraries to link with for pvfs2])])

    temp_with_pvfs2="$with_pvfs2"
    AS_IF([test -z "$with_pvfs2"],
          [with_pvfs2="/usr/local"])

    temp_with_pvfs2_libs="$with_pvfs2_libs"
    AS_IF([test -z "$with_pvfs2_libs"],
	[with_pvfs2_libs="pvfs2 pthread"])
    
    # Add correct -I and -L flags
    AS_IF([test -d "$with_pvfs2/include"],
        [check_pvfs2_CPPFLAGS="-I$with_pvfs2/include"
            $1_CPPFLAGS="$check_pvfs2_CPPFLAGS"
            $1_CPPFLAGS="$check_pvfs2_CPPFLAGS"
            CFLAGS="$CFLAGS $check_pvfs2_CPPFLAGS"	    
            CPPFLAGS="$CPPFLAGS $check_pvfs2_CPPFLAGS"	    
            WRAPPER_EXTRA_CPPFLAGS="$WRAPPER_EXTRA_CPPFLAGS $check_pvfs2_CPPFLAGS"
            WRAPPER_EXTRA_CFLAGS="$WRAPPER_EXTRA_CFLAGS $check_pvfs2_CPPFLAGS"], 
	[ompi_check_pvfs2_happy="no"])
    
    AS_IF([test "$ompi_check_pvfs2_happy" = "yes"],
	[AS_IF([test -d "$with_pvfs2/lib"],
		[check_pvfs2_LDFLAGS="-L$with_pvfs2/lib"
		    $1_LDFLAGS="$check_pvfs2_LDFLAGS"
		    LDFLAGS="$LDFLAGS $check_pvfs2_LDFLAGS"
		    WRAPPER_EXTRA_LDFLAGS="$WRAPPER_EXTRA_LDFLAGS $check_pvfs2_LDFLAGS"],
		[ompi_check_pvfs2_happy="no"]) 
    ],[])
	    
    # Try to find all the pvfs2 libraries
    AS_IF([test "$ompi_check_pvfs2_happy" = "yes"],
	[ AS_IF([test -n "$with_pvfs2_libs"]
		[for lib in $with_pvfs2_libs ; do
		    check_pvfs2_LIBS="$check_pvfs2_LIBS -l$lib"
		    done]) 
		
	    $1_LIBS="$check_pvfs2_LIBS"
	    LIBS="$LIBS $check_pvfs2_LIBS"
	    WRAPPER_EXTRA_LIBS="$WRAPPER_EXTRA_LIBS $check_pvfs2_LIBS"

            # check for pvfs2
	    AC_CHECK_HEADERS([pvfs2.h],
		[AC_MSG_CHECKING([if possible to link PVFS2])
		    AC_LINK_IFELSE(
			[AC_LANG_PROGRAM(
				[[#include <stdio.h>
				  #include <pvfs2.h>]],
				[[PVFS_util_resolve(NULL,NULL,NULL,0);]])],
			[AC_MSG_RESULT([yes])
			    ompi_check_pvfs2_happy="yes"],
			[AC_MSG_RESULT([no])
			    ompi_check_pvfs2_happy="no"])],
		[ompi_check_pvfs2_happy="no"])
    ])

    AS_IF([test "$ompi_check_pvfs2_happy" = "no"],
     [WRAPPER_EXTRA_LIBS="$check_pvfs2_save_wrapper_extra_libs"
	 WRAPPER_EXTRA_LDFLAGS="$check_pvfs2_save_wrapper_extra_ldflags"
	 WRAPPER_EXTRA_CFLAGS="$check_pvfs2_save_wrapper_extra_cflags"
	 WRAPPER_EXTRA_CPPFLAGS="$check_pvfs2_save_wrapper_extra_cppflags"
     ])

    LDFLAGS="$check_pvfs2_save_LDFLAGS"
    CFLAGS="$check_pvfs2_save_CFLAGS"
    CPPFLAGS="$check_pvfs2_save_CPPFLAGS"
    LIBS="$check_pvfs2_save_LIBS"

    AS_IF([test "$ompi_check_pvfs2_happy" = "yes"],
          [$2],
          [AS_IF([test ! -z "$with_pvfs2" -a "$with_pvfs2" != "no"],
                  [echo PVFS2 support not found])
              $3])

    with_pvfs2="$temp_with_pvfs2"
    with_pvfs2_libs="$temp_with_pvfs2_libs"

])

