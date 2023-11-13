@dnf5
@bz1639468
Feature: Reboot hint

Background:
    Given I enable plugin "needs_restarting"
      # Set NO_FAKE_STAT so needs-restarting sees the correct mtime on /proc/1
      # and can determine the boot time
      # And I set environment variable "NO_FAKE_STAT" to "1"
      And I use repository "dnf-ci-fedora"
      And I move the clock backward to "before boot-up"
      And I execute dnf with args "install lame kernel basesystem glibc wget lz4"
      And I move the clock forward to "the present"
      And I use repository "dnf-ci-fedora-updates"

@bz1913962
Scenario: Update core packages
    Given I execute dnf with args "upgrade kernel basesystem"
      And I execute dnf with args "upgrade glibc"
      And I execute dnf with args "upgrade lame wget"
     When I execute dnf with args "needs-restarting"
      Then the exit code is 1
      And stdout is
          """
          <REPOSYNC>
          Core libraries or services have been updated since boot-up:
            * glibc
            * kernel
            * kernel-core

          Reboot is required to fully utilize these updates.
          More information: https://access.redhat.com/solutions/27943
          """

@debug
@bz1913962
Scenario: Install a package with an associated reboot_suggested advisory
    Given I execute dnf with args "upgrade --advisory=FEDORA-2999:003-03 \*"
     When I execute dnf with args "needs-restarting"
      Then the exit code is 1
      And stdout is
          """
          <REPOSYNC>
          Core libraries or services have been updated since boot-up:
            * lz4

          Reboot is required to fully utilize these updates.
          More information: https://access.redhat.com/solutions/27943
          """

Scenario: Update non-core packages only
    Given I execute dnf with args "upgrade lame basesystem wget"
     When I execute dnf with args "needs-restarting"
     Then the exit code is 0
      And stdout is
          """
          <REPOSYNC>
          No core libraries or services have been updated since boot-up.
          Reboot should not be necessary.
          """

Scenario: -r short option (no-op for compatibility with DNF 4)
     When I execute dnf with args "needs-restarting -r"
     Then the exit code is 0

Scenario: --reboothint lon option (no-op for compatibility with DNF 4)
     When I execute dnf with args "needs-restarting --reboothint"
     Then the exit code is 0
