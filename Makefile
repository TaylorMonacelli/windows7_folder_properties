name=windows7_folder_properties

MAKEFLAGS += --warn-undefined-variables


GIT = git
MAKENSIS = makensis
RM = rm -f
UNIX2DOS = unix2dos

include VERSION.mk
version=$(majorv).$(minorv).$(microv).$(qualifierv)
version_short=$(version)

ifeq ($(qualifierv),0)
	version_short=$(majorv).$(minorv).$(microv)
	ifeq ($(microv),0)
		version_short=$(majorv).$(minorv)
	endif
endif

PRINT_DIR =
ifneq ($(findstring $(MAKEFLAGS),w),w)
	PRINT_DIR = --no-print-directory
endif

MAKENSIS_SW  =
QUIET_MAKENSIS =
QUIET_GEN =
QUIET_UNIX2DOS =
ifneq ($(findstring $(MAKEFLAGS),s),s)
ifndef V
	QUIET_MAKENSIS = @echo '   ' MAKENSIS $@;
	QUIET_UNIX2DOS = @echo '   ' UNIX2DOS $@;
	QUIET_GEN      = @echo '   ' GEN $@;
	export V

	UNIX2DOS += --quiet
	MAKENSIS_SW += /V2
endif
endif

installer=$(name)_v$(version_short).exe

changelog=$(installer)-changelog.txt



MAKENSIS_SW += /Doutfile=$(installer)
MAKENSIS_SW += /Dname="$(name)"
MAKENSIS_SW += /Dversion=$(version)



$(installer): reduce_security_powershell.bat
$(installer): HideFileExt.ps1
$(installer): windows7_folder_properties.nsi
	$(QUIET_MAKENSIS)$(MAKENSIS) $(MAKENSIS_SW) $<

upload: $(installer)
upload: $(changelog)
	-robocopy . //10.0.2.10/taylor.monacelli $^


changelog: $(changelog)
$(changelog):
	$(QUIET_GEN)$(GIT) log -m --abbrev-commit --pretty=tformat:'%h %ad %s' --date=short >$@
	$(QUIET_UNIX2DOS)$(UNIX2DOS) $@

test: $(installer)
	cmd /c $(installer)

debug: $(installer)
	cmd /c $(installer) /debug



clean:
	$(RM) $(installer)
	$(RM) Uninstall.bat
	$(RM) $(changelog)
	$(RM) windows7_folder_properties_v*.exe


.PHONY: upload
.PHONY: changelog
.PHONY: test
.PHONY: debug
.PHONY: un
.PHONY: uninstall
.PHONY: si
.PHONY: silent_install
.PHONY: test2
.PHONY: clean
