#!/bin/bash
curl -fsSL https://claude.ai/install.sh | bash

echo "alias cc='claude'" >> ~/.bashrc && source ~/.bashrc
