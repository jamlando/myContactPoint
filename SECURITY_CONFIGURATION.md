# Security Configuration Guide

## Environment Variables Required

### Production Environment Variables
Set these environment variables in your production deployment:

```bash
# Supabase Configuration
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key

# PostHog Analytics (Optional)
POSTHOG_API_KEY=phc_your-posthog-key
POSTHOG_HOST=https://us.i.posthog.com
```

### Development Environment Variables
For local development, you can use these defaults or set environment variables:

```bash
# Local Supabase Development
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxvY2FsaG9zdCIsInJvbGUiOiJhbm9uIiwiaWF0IjoxNjQwOTk1MjAwLCJleHAiOjE5NTYzNTUyMDB9.local-dev-key
```

## Security Features Implemented

### 1. Secure Configuration Management
- All sensitive data loaded from environment variables
- No hardcoded secrets in source code
- Secure fallbacks for development only
- Production builds fail if required environment variables are missing

### 2. Email Masking for Logging
- Email addresses are masked in all log output
- Format: `ta****@gmail.com` (shows first 2 characters)
- Prevents sensitive user data exposure in logs

### 3. Secure Logging Practices
- All debug logs use `os_log` with proper privacy levels
- Sensitive information masked before logging
- Error messages sanitized to prevent information leakage

### 4. File Security
- GoogleService-Info.plist contains placeholder values
- Real Firebase configuration must be provided separately
- No production credentials in version control

## Deployment Security Checklist

### Pre-Deployment
- [ ] Set all required environment variables
- [ ] Verify no hardcoded secrets in code
- [ ] Test configuration validation
- [ ] Review all log output for sensitive data

### Post-Deployment
- [ ] Verify environment variables are loaded correctly
- [ ] Test authentication flows
- [ ] Check that logs don't contain sensitive information
- [ ] Monitor for any configuration errors

## Security Best Practices

### 1. Environment Variables
- Never commit real API keys to version control
- Use different keys for development and production
- Rotate keys regularly
- Use secure key management systems in production

### 2. Logging
- Always mask sensitive data before logging
- Use appropriate log levels (debug, info, error)
- Implement log retention policies
- Monitor logs for security issues

### 3. Error Handling
- Don't expose internal system details in error messages
- Log detailed errors server-side only
- Provide user-friendly error messages
- Implement proper error sanitization

### 4. Data Protection
- Encrypt sensitive data at rest
- Use HTTPS for all network communications
- Implement proper authentication and authorization
- Follow data privacy regulations (GDPR, CCPA)

## Incident Response

If you discover exposed secrets:

1. **Immediate Actions**
   - Rotate all exposed keys immediately
   - Review access logs for unauthorized usage
   - Update all affected systems

2. **Investigation**
   - Determine scope of exposure
   - Check version control history
   - Review deployment logs

3. **Prevention**
   - Implement automated secret scanning
   - Add pre-commit hooks to prevent secret commits
   - Regular security audits
   - Team security training

## Contact

For security issues or questions, contact the development team immediately.
