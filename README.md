# dotfiles Setup 🚀

A robust dotfiles configuration with automated installation, backup, and verification features.

## ✨ Features

- **🔧 Modern ZSH Configuration** - Optimized shell setup with useful plugins
- **🔄 Automatic Backup** - Never lose your existing configuration
- **🔍 Installation Verification** - Ensures everything is set up correctly
- **🎛️ Modular Installation** - Install only what you need
- **📝 Comprehensive Logging** - Track installation progress and issues
- **🛠️ Self-Healing** - Automatic fixing of common issues
- **💻 Cross-Platform** - Works on macOS and Linux

## 📋 What's Included

### Shell Configuration
- **ZSH** with Oh My Zsh
- **Custom aliases** for productivity
- **Git aliases** for version control
- **iTerm color tab support** (macOS)
- **Auto-completion** enhancements

### Editor Configuration
- **Emacs** configuration with org-mode setup
- **Zenburn theme** for comfortable coding
- **Custom init.el** with productivity settings

### ZSH Plugins
- `zsh-autosuggestions` - Fish-like autosuggestions
- `zsh-syntax-highlighting` - Syntax highlighting
- `zsh-completions` - Additional completions
- `zsh-docker-aliases` - Docker shortcuts

### Development Tools
- **Git** configuration and aliases
- **FZF** integration for fuzzy finding
- **Modern CLI tools** (bat, exa, fd)
- **Productivity aliases** and functions

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/dot-files.git ~/.dot-files
cd ~/.dot-files

# Run the installer
./install.sh
```

That's it! The installer will:
1. Create a backup of your existing configuration
2. Install system dependencies
3. Set up Oh My Zsh and plugins
4. Create symbolic links to dotfiles
5. Set ZSH as your default shell
6. Verify the installation

## 📖 Usage

### Basic Installation

```bash
# Full installation (recommended)
./install.sh

# Show help
./install.sh --help
```

### Advanced Options

```bash
# Dry run (see what would be done)
./install.sh --dry-run

# Skip system dependencies
./install.sh --skip-system-deps

# Skip Oh My Zsh installation
./install.sh --skip-oh-my-zsh

# Skip ZSH plugins
./install.sh --skip-plugins

# Only create backup
./install.sh --backup-only

# Only verify existing installation
./install.sh --verify-only
```

### Backup Management

```bash
# Create a backup manually
./scripts/utils/backup.sh

# List files that would be backed up
./scripts/utils/backup.sh --list

# Restore from a backup
./scripts/utils/backup.sh --restore ~/.dotfiles-backup-20231201-120000
```

### Verification and Maintenance

```bash
# Verify installation
./scripts/utils/verify.sh

# Verbose verification
./scripts/utils/verify.sh --verbose

# Check and fix issues
./scripts/utils/verify.sh --fix

# Check only symlinks
./scripts/utils/verify.sh --check-links

# Check only ZSH plugins
./scripts/utils/verify.sh --check-plugins
```

## 🗂️ File Structure

```
.dot-files/
├── install.sh              # Main installer script
├── .zshrc                   # ZSH configuration
├── config/
│   └── dotfiles.yaml       # Configuration file
├── install/
│   ├── mac-install.sh       # macOS-specific setup
│   └── linux-install.sh    # Linux-specific setup
├── scripts/
│   ├── .aliases.sh          # General aliases
│   ├── .aliases-git.sh      # Git aliases
│   └── utils/
│       ├── backup.sh        # Backup utility
│       └── verify.sh        # Verification utility
├── .config/
│   └── emacs/              # Emacs configuration
│       ├── init.el         # Main Emacs config
│       ├── early-init.el   # Early initialization
│       ├── config.org      # Org-mode configuration
│       └── themes/
│           └── zenburn-theme.el # Custom theme
└── README.md               # This file
```

## ⚙️ Configuration

The installation behavior can be customized by editing `config/dotfiles.yaml`:

```yaml
# Enable/disable features
options:
  set_default_shell: true
  install_oh_my_zsh: true
  install_packages: true
  create_backup: true
  verify_installation: true

# Customize symlinks
symlinks:
  ~/.zshrc: .zshrc
  ~/.aliases.sh: scripts/.aliases.sh
  # Add your own...
```

## 🔧 Customization

### Adding Your Own Aliases

Edit `scripts/.aliases.sh` to add your personal aliases:

```bash
# Your custom aliases
alias myalias="my command"
alias shortcuts="echo 'My shortcuts'"
```

### Adding ZSH Plugins

Add new plugins to `config/dotfiles.yaml`:

```yaml
zsh_plugins:
  - name: my-plugin
    url: https://github.com/user/my-plugin
    description: "My custom plugin"
```

### Platform-Specific Setup

Customize `install/mac-install.sh` or `install/linux-install.sh` for your specific needs.

## 🛠️ Troubleshooting

### Common Issues

**Installation fails with permission errors**
```bash
# Make sure scripts are executable
chmod +x install.sh scripts/utils/*.sh
```

**ZSH plugins not working**
```bash
# Verify and fix plugins
./scripts/utils/verify.sh --check-plugins --fix
```

**Symlinks are broken**
```bash
# Check and fix symlinks
./scripts/utils/verify.sh --check-links --fix
```

### Debug Mode

Enable detailed logging:
```bash
# Check installation log
cat install.log

# Run verification with verbose output
./scripts/utils/verify.sh --verbose
```

### Backup Recovery

If something goes wrong, restore from backup:
```bash
# List available backups
ls -la ~/.dotfiles-backup-*

# Restore from backup
./scripts/utils/backup.sh --restore ~/.dotfiles-backup-YYYYMMDD-HHMMSS
```

## 📚 What's Different from the Old Installer?

### 🔄 Before (Old Installer)
- ❌ No backup system
- ❌ Basic error handling
- ❌ Hard to customize
- ❌ No verification
- ❌ Prone to failures

### ✅ After (New Installer)
- ✅ **Automatic backups** with restore capability
- ✅ **Robust error handling** with detailed logging
- ✅ **Modular design** with configuration files
- ✅ **Installation verification** and self-healing
- ✅ **Idempotent operations** - safe to run multiple times
- ✅ **Command-line options** for flexibility
- ✅ **Better documentation** and troubleshooting

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- [Oh My Zsh](https://ohmyz.sh/) - Framework for managing ZSH configuration
- [Zsh Users](https://github.com/zsh-users) - Amazing ZSH plugins
- The open-source community for inspiration and tools

---

**Happy dotfiles! 🎉**

> Made with ❤️ for developers who love a clean, efficient development environment.
