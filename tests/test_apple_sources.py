"""Offline regression checks for Apple release-note status tracking."""
import unittest

from check_apple_sources import release_issue_statuses


class ReleaseIssueTests(unittest.TestCase):
    def test_known_issue_becoming_resolved_is_visible(self):
        before = "### Device Hub\n#### Known Issues\n- Capture issue.\n  (187146039)\n"
        after = before.replace("Known Issues", "Resolved Issues")
        self.assertEqual(release_issue_statuses(before), {"187146039": "Known Issues"})
        self.assertEqual(release_issue_statuses(after), {"187146039": "Resolved Issues"})

    def test_section_boundaries_and_feedback_ids(self):
        notes = """### Device Hub
#### Known Issues
- Capture issue. (187146039) (FB25077755)
### Simulator
Intro mentions an issue without classifying it. (187148389)
#### Resolved Issues
- Accessory fix.
  (190155353)
"""
        self.assertEqual(release_issue_statuses(notes), {
            "187146039": "Known Issues",
            "190155353": "Resolved Issues",
        })

    def test_removed_issue_is_not_reported_as_unchanged(self):
        self.assertNotIn("187146039", release_issue_statuses("### Device Hub\n#### Known Issues\n"))


if __name__ == "__main__":
    unittest.main()
