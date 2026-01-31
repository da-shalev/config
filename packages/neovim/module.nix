{ pkgs, lib, ... }:
{
  appName = "nvim";
  desktopEntry = true;

  providers = {
    python3.enable = false;
    ruby.enable = false;
    perl.enable = false;
    nodeJs.enable = false;
  };

  initLua = builtins.readFile ./init.lua;

  plugins = {
    dev.main =
      let
        sources = lib.fileset.unions [
          ./plugin
          ./after
          ./ftplugin
        ];
      in
      {
        pure = (
          lib.fileset.toSource {
            root = ./.;
            fileset = sources;
          }
        );
        impure = sources;
      };

    start = with pkgs.vimPlugins; [
      gruvbox-nvim
      lualine-nvim
      fzf-lua
      conform-nvim

      todo-comments-nvim

      (nvim-treesitter.withPlugins (
        p: with p; [
          tree-sitter-bash
          tree-sitter-c
          tree-sitter-cpp
          tree-sitter-css
          tree-sitter-scss
          tree-sitter-go
          tree-sitter-json5
          tree-sitter-fish
          tree-sitter-lua
          tree-sitter-nix
          tree-sitter-python
          tree-sitter-rust
          tree-sitter-wgsl
          tree-sitter-toml
          tree-sitter-astro
          tree-sitter-tsx
          tree-sitter-xml
          tree-sitter-html
          tree-sitter-typescript
          tree-sitter-javascript
          tree-sitter-vimdoc
          tree-sitter-go
          tree-sitter-yaml
        ]
      ))

      lazydev-nvim
      nvim-lspconfig
      nvim-ts-autotag

      comment-nvim
      ts-comments-nvim

      friendly-snippets
      blink-cmp

      undotree
      zen-mode-nvim
    ];
  };

  extraBinPath = with pkgs; [
    ripgrep
    fd
    stdenv.cc.cc
    vscode-langservers-extracted
    nil
    nixfmt

    lua-language-server

    tailwindcss-language-server
    yaml-language-server
    # svelte-language-server
    typescript-language-server
    typescript
    stylua
    prettier
    # mdx-language-server
    # nimlangserver
    astro-language-server

    ripgrep
    curl
    git
    fzf

    # jdt-language-server
    pyright
    # php83Packages.psalm
    # intelephense

    # deadnix
    # statix
    # editorconfig-checker
    # ruff
    # mypy
    # jq
    # yq
    # shfmt
  ];

  aliases = [
    "v"
    "vim"
  ];
}
