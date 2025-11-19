package types

import (
	"github.com/cosmos/cosmos-sdk/codec"
)

// ModuleCdc defines the evm module's codec
var ModuleCdc = codec.New()

// RegisterCodec registers all the necessary types and interfaces for the
// evm module
func RegisterCodec(cdc *codec.Codec) {
	cdc.RegisterConcrete(MsgEthereumTx{}, "impactchain/MsgEthereumTx", nil)
	cdc.RegisterConcrete(MsgImpactchain{}, "impactchain/MsgImpactchain", nil)
	cdc.RegisterConcrete(TxData{}, "impactchain/TxData", nil)
	cdc.RegisterConcrete(ChainConfig{}, "impactchain/ChainConfig", nil)
}

func init() {
	RegisterCodec(ModuleCdc)
	codec.RegisterCrypto(ModuleCdc)
	ModuleCdc.Seal()
}
