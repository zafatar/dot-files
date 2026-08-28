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
- **AWS helpers** for EC2/AMI and S3 listings
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
- **Modern CLI tools** (bat, eza, fd, duf)
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
├── install.sh                    # Main installer script
├── .zshrc                        # ZSH configuration (interactive shells)
├── .zprofile                     # ZSH configuration (login shells: Homebrew, Python, etc.)
├── install/
│   ├── mac-install.sh            # macOS-specific setup (Homebrew)
│   ├── linux-deb-install.sh      # Debian/Ubuntu setup (apt)
│   └── linux-arch-install.sh     # Arch setup (yay)
├── scripts/
│   ├── .aliases.sh               # General aliases
│   ├── .aliases-git.sh           # Git aliases
│   ├── .functions.sh             # Shell helper functions
│   ├── .aws.sh                   # Loads the AWS helpers below
│   ├── .aws_ec2.sh               # EC2 / AMI listing helpers
│   ├── .aws_s3.sh                # S3 bucket listing helpers
│   └── utils/
│       ├── backup.sh             # Backup utility
│       └── verify.sh             # Verification utility
├── .config/
│   └── emacs/                    # Emacs configuration
│       ├── init.el               # Main Emacs config
│       ├── early-init.el         # Early initialization
│       ├── config.org            # Org-mode configuration
│       └── themes/
│           └── zenburn-theme.el  # Custom theme
└── README.md                     # This file
```

## ⚙️ Configuration

There is no separate config file — the installer is configured in place:

| What | Where |
| --- | --- |
| Which files get symlinked | `create_symlinks` in `install.sh` |
| Which files get backed up | `create_backup` in `install.sh` |
| Which ZSH plugins get installed | `install_zsh_plugins` in `install.sh` |
| Which system packages get installed | `install/<platform>-install.sh` |
| What `verify.sh` checks | `check_symlinks` / `check_zsh_plugins` in `scripts/utils/verify.sh` |

When adding a symlink, add it to **both** `create_symlinks` (`install.sh`) and
`check_symlinks` (`verify.sh`), otherwise verification will not cover it.

### Package lists

The three platform installers install the same tool set. When adding a package,
add it to all three:

| Tool | macOS (brew) | Debian/Ubuntu (apt) | Arch (yay) |
| --- | --- | --- | --- |
| `bat` | `bat` | `bat` → binary `batcat` | `bat` |
| `fd` | `fd` | `fd-find` → binary `fdfind` | `fd` |
| `eza` | `eza` | `eza` (Debian 13 / Ubuntu 24.04+) | `eza` |
| `telnet` | `telnet` | `telnet` or `inetutils-telnet` | `inetutils` |

Debian's `batcat`/`fdfind` binaries are aliased back to `bat`/`fd` in
`scripts/.aliases.sh`, so the same command works everywhere. The apt installer
skips packages the running release does not have (with a warning) instead of
aborting, since `eza` and `fastfetch` are missing on older releases.

## 🔧 Customization

### Adding Your Own Aliases

Edit `scripts/.aliases.sh` to add your personal aliases:

```bash
# Your custom aliases
alias myalias="my command"
alias shortcuts="echo 'My shortcuts'"
```

### Adding ZSH Plugins

Add the plugin to the `plugins` array in `install_zsh_plugins` (`install.sh`),
to `expected_plugins` in `scripts/utils/verify.sh`, and to the `plugins=(...)`
list in `.zshrc` so ZSH actually loads it.

### Platform-Specific Setup

Customize `install/mac-install.sh`, `install/linux-deb-install.sh`, or
`install/linux-arch-install.sh` for your specific needs.

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

Released under the MIT License.

## 🙏 Acknowledgments

- [Oh My Zsh](https://ohmyz.sh/) - Framework for managing ZSH configuration
- [Zsh Users](https://github.com/zsh-users) - Amazing ZSH plugins
- The open-source community for inspiration and tools

---

**Happy dotfiles! 🎉**

> Made with ❤️ for developers who love a clean, efficient development environment.
