# LIBASR_LDFLAGS=
# LIBASR_CFLAGS=
# LIBASR_LIBS=
#
AC_DEFUN([WITH_LIBASR], [{
	AC_ARG_WITH([libasr],
		[  --with-libasr=PATH			Use libasr located in PATH],
		[
			with_libasr_include=${withval}
			if test -d "${with_libasr_include}/include"; then
				with_libasr_include="${with_libasr_include}/include"
			fi

			with_libasr_lib=${withval}
			if test -d "${with_libasr_lib}/lib"; then
				with_libasr_lib="${with_libasr_lib}/lib"
			fi

			with_libasr_cppflags="-I${with_libasr_include}"

			with_libasr_ldflags="-L${with_libasr_lib}"
			if test -n "${need_dash_r}"; then
				with_libasr_ldflags="${with_libasr_ldflags} -R${with_libasr_lib}"
			fi
		]
	)
}])

AC_DEFUN([CHECK_LIBASR], [{
	ldflags_save=$LDFLAGS
	cppflags_save=$CPPFLAGS

	if test "$with_libasr_ldflags" != ""; then
	   LDFLAGS=$with_libasr_ldflags
	fi
	if test "$with_libasr_cppflags" != ""; then
	   CPPFLAGS=$with_libasr_cppflags
	fi

	AC_CHECK_HEADER(asr.h,
		[],
		[AC_MSG_ERROR([*** could not find libasr headers (see config.log for details) ***])],
		[
			#include <sys/types.h>
			#include <sys/socket.h>
			#include <netdb.h>
		])

	AC_CHECK_LIB(asr, asr_run, [check_libasr_lib=-lasr],		# found
		[AC_CHECK_LIB(c, asr_run, [check_libasr_lib=-lc],	# found
		[AC_MSG_ERROR([*** could not find libasr library (see config.log for details) ***])],
		[])],
		[])

	# OpenBSD's libasr does not have asr_freeaddrinfo(), we need to
	# detect it so it can be worked around.
	AC_CHECK_FUNC(asr_freeaddrinfo,
		[AC_DEFINE([HAVE_ASR_FREEADDRINFO], [], [if you have asr_freeaddrinfo() in libasr])],
		[])

	LDFLAGS=$ldflags_save
	CPPFLAGS=$cppflags_save
}])