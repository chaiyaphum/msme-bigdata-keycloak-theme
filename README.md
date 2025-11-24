# msme-bigdata-keycloak-theme

Custom Keycloak theme for MSME Big Data project with SMEGP branding.

## Compatibility

- **Keycloak Version**: 26.4.5+
- **PatternFly**: 4.x / 5.x (inherited from base theme)
- **Theme API**: Modern Keycloak theme structure with parent=base

## Theme Types

This theme package includes customizations for:

- **Login** - Custom login pages with SMEGP branding
- **Account** - User account management pages
- **Admin** - Administration console styling
- **Email** - Email notification templates (text only, inherits base)
- **Welcome** - Welcome/initial setup page

## Installation

### Option 1: Manual Installation

1. Copy the entire theme directory to your Keycloak installation:
   ```bash
   cp -r msme-bigdata-keycloak-theme ${KEYCLOAK_HOME}/themes/msme-bigdata
   ```

2. Restart Keycloak server

3. In Keycloak Admin Console:
   - Go to **Realm Settings** → **Themes**
   - Select `msme-bigdata` for Login, Account, Admin, Email, and/or Welcome themes
   - Click **Save**

### Option 2: Docker Deployment

Mount the theme directory as a volume:

```dockerfile
volumes:
  - ./msme-bigdata-keycloak-theme:/opt/keycloak/themes/msme-bigdata
```

Or add to your Dockerfile:

```dockerfile
COPY msme-bigdata-keycloak-theme /opt/keycloak/themes/msme-bigdata
```

## Theme Structure

```
msme-bigdata-keycloak-theme/
├── META-INF/
│   └── keycloak-themes.json       # Theme metadata
├── login/                          # Login theme
│   ├── theme.properties
│   ├── resources/
│   │   ├── css/                   # Custom CSS
│   │   ├── js/                    # Custom JavaScript
│   │   └── img/                   # Images and logos
│   └── messages/                  # i18n message bundles
├── account/                        # Account theme
│   ├── theme.properties
│   └── resources/
├── admin/                          # Admin console theme
│   ├── theme.properties
│   └── resources/
├── email/                          # Email templates
│   ├── theme.properties
│   └── messages/
├── welcome/                        # Welcome page
│   ├── theme.properties
│   ├── index.ftl                  # FreeMarker template
│   └── resources/
└── common/                         # Shared resources
    └── resources/
        ├── node_modules/          # PatternFly, Bootstrap, etc.
        └── web_modules/           # React components

```

## Customizations

### Login Theme

- Custom SMEGP branding and colors (primary: #0177c1)
- Kanit font for Thai language support
- Custom background images
- Responsive layout with Bootstrap grid
- Multi-language support (20 languages)
- Custom JavaScript for redirect functionality

### Styling

The theme uses:
- **PatternFly** components and utilities
- **Bootstrap** grid system
- **Font Awesome** icons
- Custom CSS for SMEGP branding

### Supported Languages

Thai (TH), English (EN), German (DE), French (FR), Italian (IT), Spanish (ES), Portuguese Brazil (PT_BR), Turkish (TR), Japanese (JA), Chinese (ZH_CN), Russian (RU), Polish (PL), Czech (CS), Slovak (SK), Hungarian (HU), Lithuanian (LT), Danish (DA), Norwegian (NO), Swedish (SV), Catalan (CA)

## Development

### Modifying Styles

1. Edit CSS files in `{theme-type}/resources/css/`
2. Changes are hot-reloaded in development mode
3. For production, restart Keycloak or clear theme cache

### Adding Translations

1. Add or edit message properties in `{theme-type}/messages/messages_{locale}.properties`
2. Use format: `key=Translated text`

### Testing

Enable theme caching disable in development:

```bash
bin/kc.sh start-dev --spi-theme-static-max-age=-1 --spi-theme-cache-themes=false --spi-theme-cache-templates=false
```

## Notes

- This theme inherits all templates from Keycloak's base theme
- Only CSS, JavaScript, images, and messages are customized
- Compatible with Keycloak 26.4.5 and should work with future versions that maintain base theme compatibility
- For major Keycloak version upgrades, test thoroughly before deploying to production

## License

Based on Keycloak's default theme structure (LGPL 2.1)