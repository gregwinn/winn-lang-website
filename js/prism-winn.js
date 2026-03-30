// Prism.js language definition for Winn
Prism.languages.winn = {
  'comment': {
    pattern: /#.*/,
    greedy: true
  },
  'string': {
    pattern: /"(?:[^"\\]|\\.)*"/,
    greedy: true,
    inside: {
      'interpolation': {
        pattern: /#\{[^}]*\}/,
        inside: {
          'delimiter': {
            pattern: /^#\{|\}$/,
            alias: 'punctuation'
          },
          rest: null // filled below
        }
      }
    }
  },
  'atom': {
    pattern: /:[a-zA-Z_]\w*/,
    alias: 'symbol'
  },
  'keyword': /\b(?:module|def|end|do|if|else|elsif|unless|case|when|match|switch|for|in|while|return|use|import|alias|require|true|false|nil|and|or|not|fn|raise|try|catch|rescue|after|with|guard|cond|defp|defstruct|defprotocol|defimpl|on)\b/,
  'module-name': {
    pattern: /\b[A-Z]\w*(?:\.[A-Z]\w*)*/,
    alias: 'class-name'
  },
  'function': {
    pattern: /(?<=\.)\w+(?=\()|(?<=def\s)\w+/,
    alias: 'function'
  },
  'number': /\b\d+(?:\.\d+)?\b/,
  'operator': /\|>|<>|->|=>|\.\.|\+\+|--|&&|\|\||[+\-*\/%=<>!&|^~]+/,
  'pipe': {
    pattern: /\|>/,
    alias: 'operator'
  },
  'punctuation': /[{}[\]().,;|]/,
  'variable': {
    pattern: /\|[a-zA-Z_]\w*(?:,\s*[a-zA-Z_]\w*)*\|/,
    inside: {
      'punctuation': /\|/,
      'variable': /[a-zA-Z_]\w*/
    }
  }
};

// Allow interpolation to contain Winn expressions
Prism.languages.winn.string.inside.interpolation.inside.rest = Prism.languages.winn;
