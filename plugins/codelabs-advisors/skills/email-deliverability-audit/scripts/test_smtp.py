#!/usr/bin/env python3
"""SMTP Send/Receive Test Script for Mailcow accounts.

Usage:
    python3 test_smtp.py <from_email> <password> <to_email>
    python3 test_smtp.py --all <target_email>  (reads accounts from stdin as email:password lines)

Returns exit code 0 on success, 1 on failure.
"""
import smtplib
import sys
import time
from email.mime.text import MIMEText
from email.utils import formatdate, make_msgid

SMTP_HOST = "mail.codelabs.studio"
SMTP_PORT = 587


def send_test(from_email, password, to_email):
    domain = from_email.split("@")[1]
    ts = time.strftime("%Y-%m-%d %H:%M:%S UTC", time.gmtime())
    body = f"Deliverability test from {domain} at {ts}"
    msg = MIMEText(body, "plain", "utf-8")
    msg["Subject"] = f"[AUDIT] Test from {domain}"
    msg["From"] = from_email
    msg["To"] = to_email
    msg["Date"] = formatdate(localtime=True)
    msg["Message-ID"] = make_msgid(domain=domain)

    try:
        s = smtplib.SMTP(SMTP_HOST, SMTP_PORT, timeout=15)
        s.starttls()
        s.login(from_email, password)
        s.sendmail(from_email, to_email, msg.as_string())
        s.quit()
        print(f"OK  {from_email}")
        return True
    except smtplib.SMTPAuthenticationError as e:
        print(f"AUTH_FAIL  {from_email}: {e}")
        return False
    except Exception as e:
        print(f"ERROR  {from_email}: {e}")
        return False


if __name__ == "__main__":
    if len(sys.argv) == 4 and sys.argv[1] != "--all":
        ok = send_test(sys.argv[1], sys.argv[2], sys.argv[3])
        sys.exit(0 if ok else 1)
    elif len(sys.argv) == 3 and sys.argv[1] == "--all":
        target = sys.argv[2]
        sent = 0
        total = 0
        for line in sys.stdin:
            line = line.strip()
            if not line or ":" not in line:
                continue
            email, password = line.split(":", 1)
            total += 1
            if send_test(email.strip(), password.strip(), target):
                sent += 1
        print(f"\n--- Summary: {sent}/{total} sent ---")
        sys.exit(0 if sent == total else 1)
    else:
        print(__doc__)
        sys.exit(2)
