# Changelog

All notable changes to the MSME Big Data Keycloak Theme will be documented in this file.

## [2.0.0] - 2025-11-24

### Updated for Keycloak 26.4.5 Compatibility

#### Added
- `META-INF/keycloak-themes.json` - Theme metadata file for proper theme registration
- Comprehensive README.md with installation and usage instructions
- CHANGELOG.md to track version changes
- Version compatibility comments in all theme.properties files

#### Changed
- Updated documentation URL in `welcome/theme.properties` to use current Keycloak documentation
- Added Keycloak 26.4.5+ compatibility markers across all theme configuration files
- Enhanced README with detailed theme structure, customization guide, and deployment options

#### Technical Notes
- Theme continues to use `parent=base` inheritance for maximum compatibility
- All templates are inherited from Keycloak base theme
- Custom CSS, JavaScript, and images remain unchanged and compatible
- PatternFly 4/5 components are automatically inherited from base theme
- No breaking changes - theme is backward compatible with Keycloak 18+

#### Theme Components Updated
- **Login**: Added version compatibility comment
- **Account**: Added version compatibility comment
- **Admin**: Added version compatibility comment
- **Email**: Added version compatibility comment
- **Welcome**: Updated documentation URL and added version comment

### Testing Recommendations

When deploying to Keycloak 26.4.5:

1. Test login flows with all configured identity providers
2. Verify account management pages render correctly
3. Check email templates in all supported languages
4. Validate welcome page displays properly
5. Test theme in both light and responsive modes
6. Verify custom JavaScript redirect functionality

### Deployment

The theme is ready for deployment to Keycloak 26.4.5. Copy the entire directory to:
```
${KEYCLOAK_HOME}/themes/msme-bigdata
```

Or mount as Docker volume:
```
/opt/keycloak/themes/msme-bigdata
```

---

## [1.0.0] - Initial Release

### Features
- Custom SMEGP branding for login pages
- Multi-language support (20 languages)
- Responsive design with Bootstrap and PatternFly
- Custom account management styling
- Admin console branding
- Email templates with i18n support
- Welcome page customization
- Kanit font for Thai language support
- Custom background images and logos
