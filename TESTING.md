# Testing Guide for MSME Big Data Keycloak Theme

This guide provides comprehensive instructions for testing the Keycloak theme with version 26.4.5.

## Prerequisites

- Docker and Docker Compose installed
- OR Keycloak 26.4.5 installed locally
- Web browser (Chrome, Firefox, Safari, or Edge)

## Quick Test with Docker Compose

### 1. Start Keycloak Test Instance

Use the provided `docker-compose.test.yml`:

```bash
docker-compose -f docker-compose.test.yml up -d
```

This will start:
- Keycloak 26.4.5 on port 8080
- PostgreSQL database
- Theme automatically mounted

### 2. Access Keycloak

Wait ~30 seconds for startup, then visit:
- **URL**: http://localhost:8080
- **Admin Console**: http://localhost:8080/admin
- **Default Admin**: admin / admin

## Testing Checklist

### ✅ Welcome Page Testing

1. Navigate to http://localhost:8080
2. Verify:
   - [ ] MSME Big Data branding appears
   - [ ] Layout is responsive (test on mobile/tablet/desktop widths)
   - [ ] "Administration Console" link works
   - [ ] Documentation link points to https://www.keycloak.org/documentation
   - [ ] No console errors in browser DevTools

### ✅ Login Theme Testing

1. Go to Admin Console or create a test realm
2. Configure realm to use `msme-bigdata` theme:
   - Realm Settings → Themes → Login Theme → `msme-bigdata`
3. Test login page:
   - [ ] Custom background images load
   - [ ] SMEGP branding (blue color #0177c1) is applied
   - [ ] Kanit font renders correctly for Thai text
   - [ ] Form fields have proper PatternFly styling
   - [ ] Responsive layout works on all screen sizes
   - [ ] Custom CSS loads without errors

4. Test authentication flows:
   - [ ] Username/Password login
   - [ ] OTP/2FA selection (if configured)
   - [ ] Password reset flow
   - [ ] Registration page (if enabled)
   - [ ] Social login buttons (if configured)

5. Test multi-language support:
   - [ ] Change locale in dropdown
   - [ ] Verify translations appear correctly
   - [ ] Test Thai (TH) language specifically
   - [ ] Test at least 3 other languages

### ✅ Account Theme Testing

1. Set Account Theme to `msme-bigdata`:
   - Realm Settings → Themes → Account Theme → `msme-bigdata`
2. Login as a test user
3. Navigate to Account Console:
   - [ ] Custom styling applied
   - [ ] PatternFly components render correctly
   - [ ] Personal Info page works
   - [ ] Account Security page works
   - [ ] Applications page works
   - [ ] Resources page works (if authorization enabled)

### ✅ Admin Console Theme Testing

1. Set Admin Console Theme to `msme-bigdata`:
   - Realm Settings → Themes → Admin Console Theme → `msme-bigdata`
2. Navigate through admin sections:
   - [ ] Dashboard loads with custom styles
   - [ ] Realm settings pages work
   - [ ] User management works
   - [ ] Client configuration works
   - [ ] Custom CSS doesn't break functionality

### ✅ Email Theme Testing

1. Set Email Theme to `msme-bigdata`:
   - Realm Settings → Themes → Email Theme → `msme-bigdata`
2. Configure SMTP (or use mailcatcher/mailhog for testing)
3. Trigger email events:
   - [ ] Password reset email
   - [ ] Email verification
   - [ ] User registration confirmation
   - [ ] Test in multiple languages

4. Verify emails:
   - [ ] Custom messages (if any) appear correctly
   - [ ] Translations work
   - [ ] HTML formatting is correct
   - [ ] Links are functional

### ✅ JavaScript Functionality Testing

1. Check custom login.js:
   - [ ] Logo redirect to scoring.sme.go.th works (if applicable)
   - [ ] No JavaScript console errors
   - [ ] Custom behaviors work as expected

### ✅ Browser Compatibility Testing

Test on multiple browsers:
- [ ] Chrome/Chromium (latest)
- [ ] Firefox (latest)
- [ ] Safari (latest)
- [ ] Edge (latest)
- [ ] Mobile Safari (iOS)
- [ ] Chrome Mobile (Android)

### ✅ Performance Testing

1. Check theme loading:
   - [ ] CSS loads without FOUC (Flash of Unstyled Content)
   - [ ] Images are optimized and load quickly
   - [ ] No excessive console warnings
   - [ ] Page load time < 2 seconds

2. Check browser DevTools:
   - [ ] No 404 errors for theme resources
   - [ ] No CSS/JS errors in console
   - [ ] No mixed content warnings

### ✅ Accessibility Testing

1. Use browser accessibility tools:
   - [ ] Color contrast meets WCAG AA standards
   - [ ] Form labels are properly associated
   - [ ] Keyboard navigation works
   - [ ] Screen reader compatible

## Manual Theme Validation

Run the validation script:

```bash
./scripts/validate-theme.sh
```

This checks:
- File structure completeness
- Required files exist
- theme.properties syntax
- Image file sizes
- Common issues

## Testing with Different Keycloak Versions

### Test with Keycloak 26.4.5 (Primary Target)

```bash
docker run -d \
  -p 8080:8080 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -v $(pwd):/opt/keycloak/themes/msme-bigdata \
  quay.io/keycloak/keycloak:26.4.5 \
  start-dev
```

### Test with Latest Keycloak

```bash
docker run -d \
  -p 8080:8080 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -v $(pwd):/opt/keycloak/themes/msme-bigdata \
  quay.io/keycloak/keycloak:latest \
  start-dev
```

### Test with Keycloak 25.x (Backward Compatibility)

```bash
docker run -d \
  -p 8080:8080 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -v $(pwd):/opt/keycloak/themes/msme-bigdata \
  quay.io/keycloak/keycloak:25.0.6 \
  start-dev
```

## Troubleshooting

### Theme Not Appearing in Dropdown

1. Check theme is in correct directory: `themes/msme-bigdata/`
2. Verify `META-INF/keycloak-themes.json` exists
3. Restart Keycloak server
4. Clear browser cache
5. Check Keycloak logs for theme errors:
   ```bash
   docker logs <container-id> | grep -i theme
   ```

### CSS Not Loading

1. Check browser DevTools Network tab for 404 errors
2. Verify file paths in theme.properties match actual file locations
3. Check file permissions (must be readable by Keycloak process)
4. Disable theme cache:
   ```bash
   bin/kc.sh start-dev --spi-theme-static-max-age=-1 \
     --spi-theme-cache-themes=false \
     --spi-theme-cache-templates=false
   ```

### Images Not Displaying

1. Check image paths in CSS files
2. Verify images exist in `resources/img/`
3. Check browser console for CORS errors
4. Verify file formats are supported (PNG, JPG, SVG)

### Custom Messages Not Showing

1. Check message files are in `messages/` directory
2. Verify file naming: `messages_XX.properties` (where XX is locale)
3. Check property key names match Keycloak's expected keys
4. Verify encoding is UTF-8

### PatternFly Styles Not Applied

1. Verify `parent=base` in theme.properties
2. Check `stylesCommon` paths are correct
3. Ensure PatternFly files exist in common/resources/
4. Check browser console for CSS loading errors

## Performance Optimization

### Before Production Deployment

1. **Optimize Images**:
   ```bash
   # Install optimization tools
   npm install -g imagemin-cli imagemin-pngquant imagemin-mozjpeg

   # Optimize PNGs
   imagemin login/resources/img/*.png --plugin=pngquant --out-dir=login/resources/img/

   # Optimize JPGs
   imagemin login/resources/img/*.jpg --plugin=mozjpeg --out-dir=login/resources/img/
   ```

2. **Enable Theme Caching** in production:
   ```bash
   bin/kc.sh start --spi-theme-static-max-age=2592000
   ```

3. **Use CDN** for common resources (optional):
   - Consider serving PatternFly, Bootstrap from CDN
   - Update theme.properties accordingly

## Automated Testing (Optional)

### Selenium Test Example

```python
from selenium import webdriver
from selenium.webdriver.common.by import By

def test_login_theme_loads():
    driver = webdriver.Chrome()
    driver.get("http://localhost:8080/realms/master/account")

    # Check if custom theme is loaded
    assert "login-pf" in driver.find_element(By.TAG_NAME, "body").get_attribute("class")

    # Check custom CSS loaded
    styles = driver.execute_script(
        "return window.getComputedStyle(document.body).getPropertyValue('--pf-global-primary-color--100')"
    )

    driver.quit()
```

## Reporting Issues

When reporting issues, include:
1. Keycloak version
2. Browser and version
3. Theme component affected (login/account/admin/email/welcome)
4. Steps to reproduce
5. Screenshots
6. Browser console errors
7. Keycloak server logs

## Success Criteria

Theme is ready for production when:
- ✅ All checklist items pass
- ✅ No console errors
- ✅ Works in all major browsers
- ✅ Responsive on mobile/tablet/desktop
- ✅ All languages display correctly
- ✅ Performance is acceptable (<2s load time)
- ✅ Accessibility standards met
- ✅ Tested with actual user flows
